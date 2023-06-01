# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe 'ExternalEventRegisterManager', js: true do
  let(:group) { groups(:top_layer) }

  [:event, :course].each do |event_type|
    context "for #{event_type}" do
      let(:event) { Fabricate(event_type, attrs_for_event_type(event_type)) }
      context 'with feature toggle disabled' do
        before do
          allow(FeatureGate).to receive(:enabled?).with('groups.self_registration').and_return(false)
          allow(FeatureGate).to receive(:enabled?).with('people.people_managers').and_return(false)
        end

        it 'does not show button for registering manager' do
          visit group_public_event_path(group, event)

          expect(page).to_not have_css('btn.btn-primary[type="submit"]', text: 'Mein Kind anmelden', exact_text: true)
        end
      end

      context 'with feature toggle enabled' do
        before do
          allow(FeatureGate).to receive(:enabled?).with('groups.self_registration').and_return(false)
          allow(FeatureGate).to receive(:enabled?).with('people.people_managers').and_return(true)
        end

        it 'creates an external event manager and participation for managed' do
          visit group_public_event_path(group, event)

          find_all('#register_form input#person_email').first.fill_in(with: 'max.papi@hitobito.example.com')

          click_button('Mein Kind anmelden')

          expect(current_path).to eq(register_group_event_path(group, event))
          expect(page).to have_text('Kontaktdaten der erziehungsberechtigten Person')

          fill_in 'Vorname erziehungsberechtigte Person', with: 'Max'
          fill_in 'Nachname erziehungsberechtigte Person', with: 'Muster'
          fill_in 'Haupt-E-Mail', with: 'max.papi@hitobito.example.com'

          expect do
            find_all('.btn-toolbar.bottom .btn-group button[type="submit"]').first.click # submit
          end.to change { Person.count }.by(1)

          expect(current_path).to eq(group_event_path(group, event))

          manager = Person.find_by(email: 'max.papi@hitobito.example.com')
          expect(manager).to be_present

          expect(page).to have_text('Deine persönlichen Daten wurden aufgenommen. Du kannst nun deine Kinder via "Anmelden" Knopf anmelden')

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
          expect(new_managed.managers).to eq([manager])

          expect(current_path).to eq(new_group_event_participation_path(group, event))

          expect do
            find_all('button.btn[type="submit"]').last.click
          end.to change { Event::Participation.count }.by(1)

          expect(current_path).to eq(group_event_path(group, event))

          expect(page).to have_text(participation_success_text_for_event(event, new_managed))
        end
      end
    end
  end

  def attrs_for_event_type(type)
    attrs = { application_opening_at: 5.days.ago,
              external_applications: true, groups: [group], globally_visible: false }
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
      "#{person.full_name} ist für diesen Anlass vorangemeldet. Die Anmeldung ist noch nicht definitiv und muss von der Anlassverwaltung bestätigt werden."
    end
  end
end
