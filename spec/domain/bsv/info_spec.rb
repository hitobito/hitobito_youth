# encoding: utf-8


#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Bsv::Info do
  let(:course) { events(:top_course) }
  let(:course_year) { course.dates.first.start_at.year }
  before { course.participations.destroy_all }

  it '#location is read from course' do
    course.update!(location: 'dummy')
    expect(info.location).to eq 'dummy'
  end

  it '#vereinbarungs_id_fiver is read from kind' do
    course.kind.update!(vereinbarungs_id_fiver: 'dummy')
    expect(info.vereinbarungs_id_fiver).to eq 'dummy'
  end

  it '#kurs_id_fiver is read from kind' do
    course.kind.update!(kurs_id_fiver: 'dummy')
    expect(info.kurs_id_fiver).to eq 'dummy'
  end

  it '#training_days rounds to half days' do
    expect(Bsv::Info.new(Event::Course.new(training_days: 0.1)).training_days).to eq 0
    expect(Bsv::Info.new(Event::Course.new(training_days: 0.3)).training_days).to eq 0.5
    expect(Bsv::Info.new(Event::Course.new(training_days: 0.6)).training_days).to eq 0.5
    expect(Bsv::Info.new(Event::Course.new(training_days: 0.8)).training_days).to eq 1
    expect(Bsv::Info.new(Event::Course.new(training_days: 2.3)).training_days).to eq 2.5
    expect(Bsv::Info.new(Event::Course.new(training_days: 2.8)).training_days).to eq 3
  end

  it '#first_event_date returns first start_at date' do
    course.dates = [Event::Date.new(start_at: '2015-08-18', finish_at: '2015-08-20'),
                    Event::Date.new(start_at: '2015-08-16', finish_at: '2015-08-22')]

    expect(info.first_event_date).to eq(Date.new(2015, 8, 16))
  end

  it '#participant_count includes participant of valid age and ch residence' do
    create_participant(zip_code: 3000, birthday: Date.new(course_year - 18, 1, 1))
    expect(info.participant_count).to eq 1
  end

  it '#participant_count ignores participant of valid age withouth ch residence' do
    create_participant(birthday: Date.new(course_year - 18, 1, 1))
    expect(info.participant_count).to eq 0
  end

  it '#participant_count ignores participant born more than 30 years before course' do
    create_participant(zip_code: 3000, birthday: Date.new(course_year - 31, 12, 31))
    expect(info.participant_count).to eq 0
  end

  it '#participant_count includes participant born less than 17 years before course' do
    create_participant(zip_code: 3000, birthday: Date.new(course_year - 16, 1, 1))
    expect(info.participant_count).to eq 1
  end

  it '#participant_count ignores participant without birthday set' do
    create_participant(zip_code: 3000)
    expect(info.participant_count).to eq 0
  end

  it '#participant_count ignores non active participant of valid age and ch residence' do
    participant = create_participant(zip_code: 3000, birthday: Date.new(course_year - 18, 1, 1))
    participant.participation.update_column(:active, false)
    expect(info.participant_count).to eq 0
  end

  it '#canton_count counts distinct cantons of participants aged under 30' do
    create_participant(zip_code: 3000, birthday: Date.new(course_year - 18, 1, 1))
    create_participant(zip_code: 3000, birthday: Date.new(course_year - 18, 1, 1))
    create_participant(zip_code: 4000, birthday: Date.new(course_year - 18, 1, 1))
    create_participant(birthday: Date.new(course_year - 18, 1, 1))
    expect(info.canton_count).to eq 2
  end

  [ Event::Role::Leader, Event::Role::AssistantLeader ].each do |role_type|
    it "#leader_count includes #{role_type}" do
      create_participation(role_type)
      expect(info.leader_count).to eq 1
    end
  end

  [ Event::Role::Cook, Event::Role::Treasurer,
    Event::Role::Speaker, Event::Course::Role::Participant ].each do |role_type|
    it "#leader_count includes #{role_type}" do
      create_participation(role_type)
      expect(info.leader_count).to eq 0
    end
  end

  private

  def info
    Bsv::Info.new(course.reload)
  end

  def create_participant(person_attrs = {})
    create_participation(Event::Course::Role::Participant, Fabricate(:person, person_attrs))
  end

  def create_participation(role, person = nil)
    person ||= Fabricate(:person)
    participation = Fabricate(:event_participation, event: course, person: person)
    Fabricate(role.to_s.to_sym, participation: participation)
  end
end
