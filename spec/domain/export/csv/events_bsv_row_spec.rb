# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Csv::Events::BsvRow do

  let(:person) { ndbjs_person }
  let(:course) { fabricate_course }

  let(:row) { Export::Csv::Events::BsvRow.new(course) }
  subject { row }

  it { expect(row.fetch(:vereinbarungs_id_fiver)).to eq '4242' }
  it { expect(row.fetch(:kurs_id_fiver)).to eq '9932' }
  it { expect(row.fetch(:number)).to eq '13' }
  it { expect(row.fetch(:oldest_event_date)).to eq '11.11.2011' }

end

private
def fabricate_course
  event_kind = Fabricate(:event_kind, vereinbarungs_id_fiver: '4242', kurs_id_fiver: '9932')
  course = Fabricate(:course, kind: event_kind, number: '13')
  create_event_dates(course)
  course
end

def create_event_dates(course)
  Fabricate(:event_date, event: course, start_at: Date.parse('11.11.2011'))
  Fabricate(:event_date, event: course, start_at: Date.parse('11.11.2012'))
end
