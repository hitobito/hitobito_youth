# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::ParticipationsController do

  let(:user) { people(:top_leader) }
  let(:other_user) { people(:bottom_member) }
  let(:course) { events(:top_course) }
  let(:person) { ndbjs_person }
  let(:group) { course.groups.first }
  let(:event_role) { Fabricate(:event_role, type: Event::Role::Leader.sti_name) }
  let(:participation) { Fabricate(:event_participation, person: person, event: course, roles: [event_role], active: true) }


  context 'csv export' do

    before do
      sign_in(user)
      participation
    end

    it 'exports csv files' do
      get :index, group_id: group, event_id: course.id, format: :csv

      expect(@response.content_type).to eq('text/csv')
      expect(@response.body).to match(/^Vorname;Nachname/)
      expect(@response.body).
        to match(/^#{participation.person.first_name};#{participation.person.last_name}/)
    end

    it 'exports csv ndbjs' do
      get :index, group_id: group, event_id: course.id, format: :csv, ndbjs: true

      expect(@response.content_type).to eq('text/csv')
      expect(@response.body).to match(/^#{ndbjs_csv_header}/)
      expect(@response.body).
        to match(/#{person_ndbjs_csv_row}/)

    end

    it 'exports csv sportdb' do
      get :index, group_id: group, event_id: course.id, format: :csv, sportdb: true

      expect(@response.content_type).to eq('text/csv')
      expect(@response.body).to match(/^#{sportdb_csv_header}/)
      expect(@response.body).
        to match(/#{person_sportdb_csv_row}/)

    end
  end

  private
  def ndbjs_person
    Location.create!(zip_code: 4000, name: 'Basel', canton: 'BS')
    person = Fabricate(:person, 
                       email: 'foo@e.com',
                       first_name: 'Peter',
                       last_name: 'Muster',
                       birthday: '11.06.1980',
                       gender: 'm',
                       j_s_number: '123',
                       ahv_number: '789',
                       address: 'Str',
                       zip_code: '4000',
                       town: 'Basel',
                       country: 'AT',
                       nationality_j_s: 'FL'
                      )
    create_contactables(person)
    person
  end

  def create_contactables(person)
    Fabricate(:phone_number, contactable: person, label: 'Privat', number: '11')
    Fabricate(:phone_number, contactable: person, label: 'Arbeit', number: '42')
    Fabricate(:phone_number, contactable: person, label: 'Mobil', number: '99')
    Fabricate(:phone_number, contactable: person, label: 'Fax', number: '33')
  end

  def ndbjs_csv_header
    %w( NDS_PERSONEN_NR 
        GESCHLECHT 
        NAME 
        VORNAME
        GEBURTSDATUM
        AHV_NUMMER
        STRASSE
        PLZ
        ORT
        KANTON
        LAND
        TELEFON_PRIVAT
        TELEFON_GESCHAEFT
        TELEFON_MOBIL
        FAX
        EMAIL
        NATIONALITAET
        ERSTSPRACHE
        ZWEITSPRACHE
        BERUF
        VERPFLICHT_ORG
        VERPFLICHT_VERB
        TAETIGKEIT
        BEILAGEN
    ).join(';')
  end

  def sportdb_csv_header
    %w( NDS_PERSONEN_NR
        GESCHLECHT
        NAME
        VORNAME
        GEB_DATUM
        STRASSE
        PLZ
        ORT
        LAND
        NATIONALITAET
        ERSTSPRACHE
        KLASSE/GRUPPE
    ).join(';')
  end

  def person_sportdb_csv_row
    %w(123 1 Muster Peter 11.06.1980 Str 4000 Basel A FL D).join(';')
  end

  def person_ndbjs_csv_row
    (%w(123 1 Muster Peter 11.06.1980 789 Str 4000 Basel BS A 11 42 99 33 foo@e.com FL D) +
      ['', '3', '', '', '1', '1']).join(';')
  end

end
