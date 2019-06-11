#  Copyright (c) 2017-2019, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::EventParticipationsExportJob do

  subject { Export::EventParticipationsExportJob.new(format,
                                                     user.id,
                                                     event_participation_filter,
                                                     params.merge(filename: 'event_participation_export')) }

  let(:user)          { people(:top_leader) }
  let(:other_user)    { people(:bottom_member) }
  let(:course)        { events(:top_course) }
  let(:person)        { ndbjs_person }
  let(:group)         { course.groups.first }
  let(:event_role)    { Fabricate(:event_role, type: Event::Role::Leader.sti_name) }
  let(:participation) { Fabricate(:event_participation, person: person, event: course, roles: [event_role], active: true) }
  let(:event_participation_filter) { Event::ParticipationFilter.new(course, user, params) }
  let(:filepath)      { AsyncDownloadFile::DIRECTORY.join('event_participation_export') }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
    participation
  end

  context 'exports csv files' do
    let(:format) { :csv }
    let(:params) { { filter: 'all' } }

    it 'and saves it' do
      subject.perform

      lines = File.readlines("#{filepath}.#{format}")
      expect(lines.size).to eq(4)
      expect(lines[0]).to match(/^Vorname;Nachname/)
      expect(lines[0].split(';').count).to match(18)
    end
  end

  context 'exports csv ndbjs' do
    let(:format) { :csv }
    let(:params) { { filter: 'all', ndbjs: true } }

    it 'and saves it' do
      subject.perform

      lines = File.readlines("#{filepath}.#{format}")
      expect(lines.size).to eq(4)
      expect(lines[0]).to match(/#{ndbjs_csv_header}/)
      expect(lines[3]).to match(/#{person_ndbjs_csv_row}/)
      expect(lines[0].split(';').count).to match(24)
    end
  end

  context 'exports csv sportdb' do
    let(:format) { :csv }
    let(:params) { { filter: 'all', sportdb: true } }

    it 'and saves it' do
      subject.perform

      lines = File.readlines("#{filepath}.#{format}")
      expect(lines.size).to eq(4)
      expect(lines[0]).to match(/#{sportdb_csv_header}/)
      expect(lines[3]).to match(/#{person_sportdb_csv_row}/)
      expect(lines[0].split(';').count).to match(13)
    end
  end

  private

  def ndbjs_person
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
                       country: 'CH',
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
    %w( NDBJS_PERS_NR
        GESCHLECHT
        NAME
        VORNAME
        GEB_DATUM
        AHV_NR
        STRASSE
        PLZ
        ORT
        LAND
        NATIONALITAET
        ERSTSPRACHE
        KLASSE/GRUPPE
    ).join(';')
  end

  def person_ndbjs_csv_row
    (%w(123 1 Muster Peter 11.06.1980 789 Str 4000 Basel BS CH 11 42 99 33 foo@e.com FL D) +
      ['', '3', '', '', '1', '1']).join(';')
  end

  def person_sportdb_csv_row
    %w(123 1 Muster Peter 11.06.1980 789 Str 4000 Basel CH FL D).join(';')
  end
end
