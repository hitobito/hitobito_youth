# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'
require_relative '../../db/migrate/20230126155336_migrate_nationality_to_new_nds.rb'

describe MigrateNationalityToNewNds do
  let(:migration) { described_class.new.tap { |m| m.verbose = false } }

  context 'up' do
    it 'updates nationality_j_s from DIV to ANDERE' do
      person_with_div_nationality = Fabricate(:person)
      person_with_div_nationality.update_attribute(:nationality_j_s, 'DIV') # not in Person::NATIONALITIES_J_S

      person_with_ch_nationality = Fabricate(:person, nationality_j_s: 'CH')

      event_contact_data_for_div_person = Event::ParticipationContactData.new(events(:top_event),
                                                                              person_with_div_nationality)
      expect(person_with_div_nationality.nationality_j_s).to eq('DIV')
      expect(event_contact_data_for_div_person.nationality_j_s).to eq('DIV')
      expect(person_with_ch_nationality.nationality_j_s).to eq('CH')

      migration.up
      Person.reset_column_information

      expect(person_with_div_nationality.reload.nationality_j_s).to eq('ANDERE')
      expect(event_contact_data_for_div_person.nationality_j_s).to eq('ANDERE')
      expect(person_with_ch_nationality.reload.nationality_j_s).to eq('CH')
    end
  end

  context 'down' do
    it 'updates nationality_j_s from ANDERE to DIV' do
      person_with_andere_nationality = Fabricate(:person)
      person_with_andere_nationality.update_attribute(:nationality_j_s, 'ANDERE')

      person_with_ch_nationality = Fabricate(:person, nationality_j_s: 'CH')

      event_contact_data_for_div_person = Event::ParticipationContactData.new(events(:top_event),
                                                                              person_with_andere_nationality)
      expect(person_with_andere_nationality.nationality_j_s).to eq('ANDERE')
      expect(event_contact_data_for_div_person.nationality_j_s).to eq('ANDERE')
      expect(person_with_ch_nationality.nationality_j_s).to eq('CH')

      migration.down
      Person.reset_column_information

      expect(person_with_andere_nationality.reload.nationality_j_s).to eq('DIV')
      expect(event_contact_data_for_div_person.nationality_j_s).to eq('DIV')
      expect(person_with_ch_nationality.reload.nationality_j_s).to eq('CH')
    end
  end
end
