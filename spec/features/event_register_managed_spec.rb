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
            expect(page).to have_css('ul.dropdown-menu li a.disabled', text: "#{managed.full_name} (Ist bereits angemeldet)", exact_text: true)
          end

          it 'shows disabled dropdown option for existing managed since they can not see the event' do
            managed_from_different_layer = Fabricate(Group::BottomLayer::Member.sti_name.to_sym, group: groups(:bottom_layer_two)).person
            user.manageds += [managed_from_different_layer]

            visit group_event_path(group, event)

            expect(page).to have_css('a.dropdown-toggle', text: /Anmelden/i)
            find('a.dropdown-toggle', text: /Anmelden/i).click
            expect(page).to have_css('ul.dropdown-menu li a.disabled', text: "#{managed_from_different_layer.full_name} (Darf den Anlass nicht sehen)", exact_text: true)
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
