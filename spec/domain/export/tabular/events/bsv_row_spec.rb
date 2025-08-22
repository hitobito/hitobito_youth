# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Tabular::Events::BsvRow do

  let(:course) { fabricate_course }

  let(:row) { Export::Tabular::Events::BsvRow.new(course) }
  subject { row }

  it { expect(row.fetch(:vereinbarungs_id_fiver)).to eq '4242' }
  it { expect(row.fetch(:kurs_id_fiver)).to eq '9932' }
  it { expect(row.fetch(:number)).to eq '13' }
  it { expect(row.fetch(:first_event_date)).to eq '11.11.2011' }
  it { expect(row.fetch(:location)).to eq 'Baumhaus im Wald, Blumenstein' }
  it { expect(row.fetch(:training_days)).to eq 11.5 }
  it { expect(row.fetch(:participant_count)).to eq 3 }
  it { expect(row.fetch(:leader_count)).to eq 2 }
  it { expect(row.fetch(:canton_count)).to eq 2 }
  it { expect(row.fetch(:language_count)).to eq 1 }

  private

  def fabricate_course
    event_kind = Fabricate(:event_kind, vereinbarungs_id_fiver: '4242', kurs_id_fiver: '9932')
    course = Fabricate(:course, kind: event_kind, number: '13')
    course.update(location: 'Baumhaus im Wald, Blumenstein')
    course.update(training_days: 11.35)
    create_event_dates(course)
    create_participations(course)
    create_leader_participations(course)
    course
  end

  def create_event_dates(course)
    Fabricate(:event_date, event: course, start_at: Date.parse('11.11.2011'))
    Fabricate(:event_date, event: course, start_at: Date.parse('11.11.2012'))
  end

  def create_participations(course)
    year = course.dates.order(:start_at).first.start_at.year
    create_participation(course, Date.new(y=year-16, m=12, d=31), 3000)
    create_participation(course, Date.new(y=year-17, m=1, d=1), 4000)
    create_participation(course, Date.new(y=year-30, m=12, d=31), 3000)
    create_participation(course, Date.new(y=year-31, m=1, d=1), 3000)
    create_participation(course, Date.new(y=year-25, m=6, d=6), '4000', false)
  end

  def create_participation(course, birthday, zip_code = '3000', active = true)
    person = Fabricate(:person, birthday: birthday, zip_code: zip_code)
    participation = Fabricate(:event_participation, event: course, participant: person)
    Fabricate(:'Event::Course::Role::Participant', participation: participation)
    state = active ? 'assigned' : 'absent'
    participation.update(state: state, active: active)
  end

  def create_leader_participations(course)
    create_leader_participation(course, 'Event::Role::Leader')
    create_leader_participation(course, 'Event::Role::AssistantLeader')
    create_leader_participation(course, 'Event::Role::Cook')
    create_leader_participation(course, 'Event::Role::Speaker')
  end

  def create_leader_participation(course, role)
    person = Fabricate(:person)
    participation = Fabricate(:event_participation, event: course, participant: person)
    Fabricate(role.to_sym, participation: participation)
  end
end

