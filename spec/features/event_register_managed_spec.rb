# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe 'EventRegisterManaged', js: true do
  let(:bottom_member) { people(:bottom_member) }
  let(:bottom_leader) { people(:bottom_leader) }
  let(:group) { groups(:bottom_layer_one) }

  let(:user) { bottom_leader }

  before { sign_in(user) }

  [:event, :course].each do |event_type|
    context "for #{event_type}" do
      let(:event) { Fabricate(event_type, attrs_for_event_type(event_type)) }

      describe 'registering existing managed' do
        let(:managed) { bottom_member }

        before do
          user.manageds = [managed]
          user.save!
        end

        context 'with feature toggle disabled' do
          before do
            allow(FeatureGate).to receive(:enabled?).with('people.people_managers').and_return(false)
          end

          it 'does not show dropdown option for existing managed' do
            visit group_event_path(group, event)

            expect(page).to_not have_css('a.dropdown-toggle', text: /Anmelden/i)
            expect(page).to_not have_css('dropdown-menu a', text: managed.full_name, exact_text: true)
            expect(page).to have_css('a.btn', text: /Anmelden/i, exact_text: true)
          end
        end

        context 'with feature toggle enabled' do
          before do
            allow(FeatureGate).to receive(:enabled?).with('people.people_managers').and_return(true)
          end

          it 'shows dropdown option for existing managed' do
            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: /Anmelden/i)
            find('a.dropdown-toggle', text: /Anmelden/i).click
            expect(page).to have_css('ul.dropdown-menu li a', text: managed.full_name, exact_text: true)
          end

          it 'shows disabled dropdown option for existing managed since theyre already participating' do
            Event::Participation.create(event: event, person: managed)

            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: /Anmelden/i)
            find('a.dropdown-toggle', text: /Anmelden/i).click
            expect(page).to have_css('ul.dropdown-menu li a.disabled', text: "#{managed.full_name} (ist bereits angemeldet)", exact_text: true)
          end

          it 'allows you to create new participation for managed' do
            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: /Anmelden/i)
            find('a.dropdown-toggle', text: /Anmelden/i).click
            expect(page).to have_css('ul.dropdown-menu li a', text: managed.full_name, exact_text: true)
            find('ul.dropdown-menu li a', text: managed.full_name, exact_text: true).click

            contact_data_path = contact_data_group_event_participations_path(group, event)
            expect(current_path).to eq(contact_data_path)

            expect(page).to have_field('Vorname', with: managed.first_name)
            expect(page).to have_field('Nachname', with: managed.last_name)

            find_all('button.btn[type="submit"]').last.click

            expect(current_path).to eq(new_group_event_participation_path(group, event))

            expect do
              find_all('button.btn[type="submit"]').last.click
            end.to change { Event::Participation.count }.by(1)

            expect(page).to have_content(participation_success_text_for_event(event, managed))
          end

        end
      end

      describe 'registering new managed' do
        context 'with feature toggle disabled' do
          before do
            allow(FeatureGate).to receive(:enabled?).with('people.people_managers').and_return(false)
          end

          it 'does not show dropdown option for new managed' do
            visit group_event_path(group, event)

            expect(page).to_not have_css('a.dropdown-toggle', text: 'Anmelden', exact_text: true)
            expect(page).to_not have_css('dropdown-menu a', text: 'Neues Kind erfassen und anmelden', exact_text: true)
            expect(page).to have_css('a.btn', text: 'Anmelden', exact_text: true)
          end
        end

        context 'with feature toggle enabled' do
          before do
            allow(FeatureGate).to receive(:enabled?).with('people.people_managers').and_return(true)
          end

          it 'shows dropdown option for new managed' do
            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: 'Anmelden', exact_text: true)
            find('a.dropdown-toggle', text: 'Anmelden', exact_text: true).click
            expect(page).to have_css('ul.dropdown-menu li a', text: 'Neues Kind erfassen und anmelden', exact_text: true)
          end

          it 'allows you to create new managed even if you cancel before creating participation' do
            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: 'Anmelden', exact_text: true)
            find('a.dropdown-toggle', text: 'Anmelden', exact_text: true).click
            expect(page).to have_css('ul.dropdown-menu li a', text: 'Neues Kind erfassen und anmelden', exact_text: true)
            find('ul.dropdown-menu li a', text: 'Neues Kind erfassen und anmelden', exact_text: true).click

            contact_data_path = contact_data_managed_group_event_participations_path(group, event)
            expect(current_path).to eq(contact_data_path)

            fill_in('Vorname', with: 'Bob')
            fill_in('Nachname', with: 'Miller')

            expect do
              find_all('button.btn[type="submit"]').last.click
            end.to change { Person.count }.by(1)

            new_managed = Person.last
            expect(new_managed.managers).to eq([user])

            expect(current_path).to eq(new_group_event_participation_path(group, event))

            expect do
              find('a.cancel').click
            end.to_not change { Event::Participation.count }

            new_managed.reload
            expect(new_managed).to be_present
            expect(new_managed.managers).to eq([user])

            expect(current_path).to eq(group_event_path(group, event))
          end

          it 'allows you to create new managed and participation for said person' do
            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: 'Anmelden', exact_text: true)
            find('a.dropdown-toggle', text: 'Anmelden', exact_text: true).click
            expect(page).to have_css('ul.dropdown-menu li a', text: 'Neues Kind erfassen und anmelden', exact_text: true)
            find('ul.dropdown-menu li a', text: 'Neues Kind erfassen und anmelden', exact_text: true).click

            contact_data_path = contact_data_managed_group_event_participations_path(group, event)
            expect(current_path).to eq(contact_data_path)

            fill_in('Vorname', with: 'Bob')
            fill_in('Nachname', with: 'Miller')

            expect do
              find_all('button.btn[type="submit"]').last.click
            end.to change { Person.count }.by(1)

            new_managed = Person.last
            expect(new_managed.managers).to eq([user])

            expect(current_path).to eq(new_group_event_participation_path(group, event))

            expect do
              find_all('button.btn[type="submit"]').last.click
            end.to change { Event::Participation.count }.by(1)

            expect(page).to have_content(participation_success_text_for_event(event, new_managed))
          end
        end
      end
    end
  end

  def attrs_for_event_type(type)
    attrs = { application_opening_at: 5.days.ago, groups: [group], globally_visible: false }
    case type
    when :course
      attrs.merge!(state: :application_open)
    end
    attrs
  end

  def participation_success_text_for_event(event, person)
    case event.class.sti_name
    when Event.sti_name
      "Teilnahme von #{person.full_name} in #{event.name} wurde erfolgreich erstellt."
    when Event::Course.sti_name
      "Es wurde eine Voranmeldung für Teilnahme von #{person.full_name} in #{event.name} erstellt"
    end
  end
end
