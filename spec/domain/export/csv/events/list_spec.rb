# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Export::Csv::Events::List do

  let(:courses) { double('courses', map: [], first: nil) }
  let(:list)  { Export::Csv::Events::List.new(courses) }
  subject { list }

  context 'used labels' do
    subject { list }

    its(:attributes) do
      should == [:name, :group_names, :number, :kind, :description, :state, :location,
                 :date_0_label, :date_0_location, :date_0_duration,
                 :date_1_label, :date_1_location, :date_1_duration,
                 :date_2_label, :date_2_location, :date_2_duration,
                 :contact_name, :contact_address, :contact_zip_code, :contact_town,
                 :contact_email, :contact_phone_numbers,
                 :leader_name, :leader_address, :leader_zip_code, :leader_town,
                 :leader_email, :leader_phone_numbers,
                 :motto, :cost, :application_opening_at, :application_closing_at,
                 :maximum_participants, :external_applications, :priorization, :training_days,
                 :teamer_count, :participant_count, :applicant_count,
                 :male_count, :female_count, :canceled_count, :absent_count, :rejected_count]
    end

    its(:labels) do
      should == ['Name', 'Organisatoren', 'Kursnummer', 'Kursart', 'Beschreibung', 'Status', 'Ort / Adresse',
                 'Datum 1 Bezeichnung', 'Datum 1 Ort', 'Datum 1 Zeitraum',
                 'Datum 2 Bezeichnung', 'Datum 2 Ort', 'Datum 2 Zeitraum',
                 'Datum 3 Bezeichnung', 'Datum 3 Ort', 'Datum 3 Zeitraum',
                 'Kontaktperson Name', 'Kontaktperson Adresse', 'Kontaktperson PLZ',
                 'Kontaktperson Ort', 'Kontaktperson Haupt-E-Mail', 'Kontaktperson Telefonnummern',
                 'Hauptleitung Name', 'Hauptleitung Adresse', 'Hauptleitung PLZ', 'Hauptleitung Ort',
                 'Hauptleitung Haupt-E-Mail', 'Hauptleitung Telefonnummern',
                 'Motto', 'Kosten', 'Anmeldebeginn', 'Anmeldeschluss', 'Maximale Teilnehmerzahl',
                 'Externe Anmeldungen', 'Priorisierung', 'Ausbildungstage', 'Anzahl Leitungsteam',
                 'Anzahl Teilnehmende', 'Anzahl Anmeldungen', 'Anzahl Teilnehmende Männer',
                 'Anzahl Teilnehmende Frauen', 'Anzahl Abgemeldete', 'Anzahl Nicht erschienene',
                 'Anzahl Abgelehnte']
    end
  end


  context 'to_csv' do
    let(:courses) { Event::Course.where(id: course) }
    let(:course) { Fabricate(:course, groups: [groups(:top_group)], location: 'somewhere', state: 'completed', training_days: 7)  }
    let(:csv) { Export::Csv::Generator.new(list).csv.split("\n")  }

    context 'headers' do
      subject { csv.first }
      it { is_expected.to match(/^Name;Organisatoren;Kursnummer;Kursart;.*Anzahl Abgelehnte$/) }
    end

    context 'first row' do
      subject { csv.second.split(';') }
      its([1]) { is_expected.to eq 'TopGroup' }
      its([5]) { is_expected.to eq 'Qualifikationen erfasst' }
      its([6]) { is_expected.to eq 'somewhere' }
      its([35]) { is_expected.to eq '7.0' } # training_days
    end

    context 'with participant counts' do
      # create a realistic base query to test count queries.
      let(:courses) { Event::Course.in_year(2012).where(id: [course1, course2, course3]).uniq }
      let(:course1) do
        c = Fabricate(:course, groups: [groups(:top_group)], motto: 'All for one', cost: 1000,
                  application_opening_at: '01.01.2000', application_closing_at: '01.02.2000',
                  maximum_participants: 10, external_applications: false, priorization: false)
        Fabricate(:event_date, event: c, start_at: Date.new(2012, 3, 5))
        Fabricate(:event_date, event: c, start_at: Date.new(2012, 4, 1))
        c
      end
      let(:course2) { Fabricate(:course, groups: [groups(:top_group)]) }
      let(:course3) { Fabricate(:course, groups: [groups(:top_group)]) }

      before do
        Fabricate(:event_participation, event: course1, active: true,
                  roles: [Fabricate(:event_role, type: Event::Role::Leader.sti_name)])
        Fabricate(:event_participation, event: course1, active: true, state: 'assigned',
                  person: Fabricate(:person, gender: 'm'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course1, active: true, state: 'attended',
                  person: Fabricate(:person, gender: 'm'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course1, active: true, state: 'assigned',
                  person: Fabricate(:person, gender: 'w'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course1, active: false, state: 'applied',
                  person: Fabricate(:person, gender: 'w'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course1, active: false, state: 'rejected',
                  person: Fabricate(:person, gender: 'w'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course1, active: false, state: 'rejected',
                  person: Fabricate(:person, gender: 'w'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course1, active: false, state: 'absent',
                  person: Fabricate(:person, gender: 'w'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        Fabricate(:event_participation, event: course2, active: false, state: 'rejected',
                  person: Fabricate(:person, gender: 'w'),
                  roles: [Fabricate(:event_role, type: Event::Course::Role::Participant.sti_name)])
        course1.refresh_participant_counts!
        course2.refresh_participant_counts!
      end

      context 'second row' do
        let(:row) { csv[1].split(';') }
        it 'should contain contain the count fields' do
          expect(row[-7..-1]).to eq %w(3 5 2 1 0 1 2)
        end
      end

      context 'third row (course with only revoked participants)' do
        let(:row) { csv[2].split(';') }
        it 'should contain empty count fields' do
          expect(row[-7..-1]).to eq %w(0 0 0 0 0 0 1)
        end
      end

      context 'fourth row (course without participants)' do
        let(:row) { csv[3].split(';') }
        it 'should contain empty count fields' do
          expect(row[-7..-1]).to eq %w(0 0 0 0 0 0 0)
        end
      end
    end
  end

  context 'for simple events' do
    let(:courses) { Event.where(id: event) }
    let(:event) { Fabricate(:event, groups: [groups(:top_group)], location: 'somewhere') }
    let(:csv) { Export::Csv::Generator.new(list).csv.split("\n")  }

    context 'headers' do
      subject { csv.first }
      it { is_expected.to match(/^Name;Organisatoren;Beschreibung;Ort.*Anzahl Anmeldungen$/) }
    end

    context 'first row' do
      subject { csv.second.split(';') }
      its([1]) { is_expected.to eq 'TopGroup' }
      its([3]) { is_expected.to eq 'somewhere' }
    end
  end

end
