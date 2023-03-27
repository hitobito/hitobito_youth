# encoding: utf-8

#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.


require 'spec_helper'
require 'csv'

describe Export::Tabular::People::PeopleEducationList do

  let(:top_leader) { people(:top_leader) }
  let(:sl) { qualification_kinds(:sl) }
  Event::Course
  let!(:course) { Fabricate(:course, groups: [groups(:top_group)]) }
  let!(:dummy) {course.dates.create!(start_at: 3.month.from_now, finish_at: 4.month.from_now)}
  let!(:participation) { Fabricate(:event_participation, person: top_leader, event: course) }
  let!(:qualification) { Fabricate(:qualification, person: top_leader, qualification_kind: sl, finish_at: 1.year.from_now) }

  let(:data) { Export::Tabular::People::PeopleEducationList.export(:csv, [top_leader]) }
  let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  before do
    top_leader.update(birthday: Date.new(2020, 02, 02), nickname: "Tonka")

  end

  context 'german' do
    let(:lang) { :de }

    it 'has correct headers' do
      expect(csv.headers).to eq([ 'Vorname', 'Nachname', 'Übername', 'Haupt-E-Mail', 'Geburtstag', 'Qualifikationen', 'Anmeldungen' ])
    end

    context 'first row' do
      subject { csv[0] }

      its(['Vorname']) { should eq 'Top' }
      its(['Nachname']) { should eq 'Leader' }
      its(['Übername']) { should eq "Tonka" }
      its(['Haupt-E-Mail']) { should eq 'top_leader@example.com' }
      its(['Geburtstag']) { should eq "02.02.2020"}
      its(['Qualifikationen']) { should eq 'Super Lead' }
      its(['Anmeldungen']) { should eq 'Eventus' }
    end
  end

end
