#  Copyright (c) 2017-2024, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::EventParticipationsExportJob do

  subject { Export::EventParticipationsExportJob.new(format,
                                                     user.id,
                                                     event_participation_filter,
                                                     params.merge(filename: filename)) }

  let(:user) { people(:top_leader) }
  let(:other_user) { people(:bottom_member) }
  let(:course) { events(:top_course) }
  let(:person) { nds_person }
  let(:group) { course.groups.first }
  let(:event_role) { Fabricate(:event_role, type: Event::Role::Leader.sti_name) }
  let(:participation) { Fabricate(:event_participation, person: person, event: course, roles: [event_role], active: true) }
  let(:event_participation_filter) { Event::ParticipationFilter.new(course, user, params) }
  let(:filename) { AsyncDownloadFile.create_name('event_participation_export', user.id) }
  let(:file) { AsyncDownloadFile.from_filename(filename, format) }

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

      lines = file.read.lines
      expect(lines.size).to eq(4)
      expect(lines[0]).to match(Regexp.new("^#{Export::Csv::UTF8_BOM}Vorname;Nachname"))
      expect(lines[0].split(';').count).to match(16)
      expect(file.generated_file).to be_attached
    end
  end

  context 'exports csv nds' do
    let(:format) { :csv }
    let(:params) { { filter: 'all', nds_course: true } }

    it 'and saves it' do
      subject.perform

      lines = file.read.lines
      expect(lines.size).to eq(4)
      expect(lines[0]).to eq("#{Export::Csv::UTF8_BOM}#{nds_course_csv_header}\n")
      expect(lines[3]).to eq("#{person_nds_csv_row}\n")
      expect(lines[0].split(';').count).to match(21)
      expect(file.generated_file).to be_attached
    end
  end

  context 'exports csv sportdb' do
    let(:format) { :csv }
    let(:params) { { filter: 'all', nds_camp: true } }

    it 'and saves it' do
      expect(FeatureGate.enabled?('structured_addresses')).to be_truthy
      subject.perform

      lines = file.read.lines
      expect(lines.size).to eq(4)
      expect(lines[0]).to eq("#{Export::Csv::UTF8_BOM}#{nds_camp_csv_header}\n")
      expect(lines[0].split(';').count).to match(14)
      expect(lines[3]).to eq("#{person_sportdb_csv_row}\n")
      expect(file.generated_file).to be_attached
    end
  end

  private

  def nds_person
    person = Fabricate(:person,
                       email: 'foo@e.com',
                       first_name: 'Peter',
                       last_name: 'Muster',
                       birthday: '11.06.1980',
                       gender: 'm',
                       j_s_number: '123',
                       ahv_number: '756.1234.5678.97',
                       street: 'Str',
                       housenumber: '',
                       zip_code: '4000',
                       town: 'Basel',
                       country: 'CH',
                       nationality_j_s: 'FL'
                      )
    create_contactables(person)
    person
  end

  def create_contactables(person)
    Fabricate(:phone_number, contactable: person, label: 'Privat', number: '+41 31 123 45 11')
    Fabricate(:phone_number, contactable: person, label: 'Arbeit', number: '+41 32 123 45 42')
    Fabricate(:phone_number, contactable: person, label: 'Mobil', number: '+41 77 123 45 99')
    Fabricate(:phone_number, contactable: person, label: 'Fax', number: '+41 31 123 45 33')
  end

  def nds_course_csv_header
    [
     'PERSONENNUMMER',
     'NAME',
     'VORNAME',
     'GEBURTSDATUM',
     'GESCHLECHT',
     'AHV_NR',
     'PEID',
     'NATIONALITAET',
     'MUTTERSPRACHE',
     'ZWEITSPRACHE',
     'STRASSE',
     'HAUSNUMMER',
     'PLZ',
     'ORT',
     'LAND',
     'TELEFON (PRIVAT)',
     'TELEFON (AMTLICH)',
     'TELEFON (GESCHAEFT)',
     'EMAIL (PRIVAT)',
     'EMAIL (AMTLICH)',
     "EMAIL (GESCHAEFT)"
    ].join(';')
  end

  def nds_camp_csv_header
    %w(
     PERSONENNUMMER
     NAME
     VORNAME
     GEBURTSDATUM
     GESCHLECHT
     AHV_NR
     PEID
     NATIONALITAET
     MUTTERSPRACHE
     STRASSE
     HAUSNUMMER
     PLZ
     ORT
     LAND
    ).join(';')
  end

  def person_nds_csv_row
    [
      '123',
      'Muster',
      'Peter',
      '11.06.1980',
      'm',
      '756.1234.5678.97',
      '', 'FL',
      'DE',
      '',
      'Str',
      '',
      '4000',
      'Basel',
      'CH',
      '\'+41 31 123 45 11',
      '',
      '\'+41 32 123 45 42',
      'foo@e.com',
      '',
      '',
    ].join(';')
  end

  def person_sportdb_csv_row
    [
      '123',
      'Muster',
      'Peter',
      '11.06.1980',
      'm',
      '756.1234.5678.97',
      '',
      'FL',
      'DE',
      'Str',
      '',
      '4000',
      'Basel',
      'CH'
    ].join(';')
  end
end
