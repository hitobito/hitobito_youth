# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::Participation do
  let(:course) { events(:top_course) }

  describe '#state' do
    let(:event) { Fabricate(:course, groups: [groups(:bottom_layer_one)], kind: event_kinds(:slk)) }
    let(:person) { people(:bottom_leader) }

    it 'sets default state' do
      p = Event::Participation.new(event: event, participant: person, state: nil)
      expect(p).to be_valid
      expect(p.state).to eq 'assigned'
    end

    it 'sets default state with application' do
      p = Event::Participation.new(event: event,
                                   participant: person,
                                   state: nil,
                                   application: Event::Application.new(priority_1: event))
      expect(p).to be_valid
      expect(p.state).to eq 'applied'
    end

    it 'does not allow "foo" state' do
      p = Event::Participation.new(event: event, participant: person, state: 'foo')
      expect(p).to_not be_valid
    end

    %w(tentative applied assigned rejected canceled attended absent).each do |state|
      it "allows \"#{state}\" state" do
        p = Event::Participation.new(event: event,
                                     participant: person,
                                     state: state,
                                     canceled_at: Time.zone.today)
        expect(p).to be_valid
      end
    end
  end

  context 'destroying tentative_applications' do
    let(:participation) { event_participations(:top_participant) }

    before { participation.update!(state: 'tentative', active: false) }

    it 'applying for that course deletes tentative participation' do
      expect do
        Fabricate(:youth_participation, event: course, participant: participation.person)
      end.not_to change { Event::Participation.count }
      expect { participation.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'applying for that course kind deletes tentative participation' do
      other_course = Fabricate(:youth_course, groups: [groups(:bottom_layer_two)])
      expect do
        Fabricate(:youth_participation, event: other_course, participant: participation.person)
      end.not_to change { Event::Participation.count }
      expect { participation.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'applying for different course kind does not delete tentative participation' do
      other_course = Fabricate(:youth_course,
                               kind: event_kinds(:glk),
                               groups: [groups(:bottom_layer_two)])
      expect do
        Fabricate(:youth_participation, event: other_course, participant: participation.person)
      end.to change { Event::Participation.count }.by(1)
      expect { participation.reload }.not_to raise_error
    end

    it 'applying with invalid state does not delete tentative participation' do
      expect do
        other = Event::Participation.create(event: course,
                                            participant: participation.person,
                                            state: 'invalid')
        expect(other.errors.full_messages).to be_present
      end.not_to change { Event::Participation.count }
      expect { participation.reload }.not_to raise_error
    end
  end

  context 'verifying participatable counts' do
    before { course.refresh_participant_counts! } # to create existing participatiots

    def create_participant(state)
      p = Fabricate(:youth_participation, event: course, state: state, canceled_at: Time.zone.today)
      p.roles.create!(type: Event::Course::Role::Participant.name)
    end

    %w(tentative canceled rejected).each do |state|
      it "creating #{state} application does not increase course#applicant_count" do
        expect { create_participant(state) }.not_to change { course.reload.applicant_count }
      end
    end

    %w(applied assigned attended absent).each do |state|
      it "creating #{state} application does increase course#application_count" do
        expect { create_participant(state) }.to change { course.reload.applicant_count }.by(1)
      end
    end
  end

  context 'canceled participations' do
    before do
      @participation = Fabricate(:youth_participation, event: course, active: false)
      @participation.roles.create!(type: Event::Course::Role::Participant.name)
    end

    def cancel_participation
      @participation.update!(state: 'canceled', canceled_at: Time.zone.today)
    end

    it 'are not listed in the upcoming-list' do
      expect(described_class.pending.count).to eq(1)
      expect { cancel_participation }.to change { described_class.pending.count }.by(-1)
    end
  end

end
