# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::Course do

  let(:event) { Fabricate(:course, groups: [groups(:bottom_layer_one)], kind: event_kinds(:slk)) }

  subject do
    Fabricate(Event::Role::Leader.name.to_sym,
              participation: Fabricate(:youth_participation, event: event))
    Fabricate(Event::Role::AssistantLeader.name.to_sym,
              participation: Fabricate(:youth_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym,
              participation: Fabricate(:youth_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym,
              participation: Fabricate(:youth_participation, event: event))
    event.reload
  end

  describe "#tentative_application_possible?" do
    it "is false  when tentative_applications flag is not set" do
      expect(Event::Course.new).not_to be_tentative_application_possible
    end

    it "is true when tentative_applications flag is set" do
      expect(Event::Course.new(tentative_applications: true)).to be_tentative_application_possible
    end
  end

  context '#organizers' do
    def person(name, role)
      group = groups(name)
      Fabricate("#{group.class.name}::#{role}", group: group).person
    end

    before do
      @one_leader = person(:bottom_layer_one, 'Leader')
      @one_guide = person(:bottom_layer_one, 'LocalGuide')

      @two_leader = person(:bottom_layer_two, 'Leader')
      @two_guide = person(:bottom_layer_two, 'LocalGuide')
    end

    it 'includes people with layer_full or layer_and_below_full from organising group' do
      expect(event.organizers).to have(3).items
      expect(event.organizers).to include(@one_leader, @one_guide)
    end

    it 'includes people from all organising event groups' do
      event.groups << groups(:bottom_layer_two)
      expect(event.organizers).to have(5).items
      expect(event.organizers).to include(@one_leader, @one_guide,
                                          @two_leader, @two_guide)
    end
  end

  context '#qualifications_visible?' do
    subject(:course) { Fabricate.build(:course, state: :completed) }

    it 'is true if kind is qualifiying and state is completed' do
      expect(course.qualifications_visible?).to be_truthy
    end

    it 'is false if kind is not qualifiying' do
      course.kind = event_kinds(:old)
      expect(course.qualifications_visible?).to be_falsy
    end

    it 'is false if state is confirmed' do
      course.state = :confirmed
      expect(course.qualifications_visible?).to be_falsy
    end
  end

  it 'updates assigned participations to attended when course closed' do
    first, second = subject.participations.joins(:roles).
      where(event_roles: { type: Event::Course::Role::Participant.sti_name }).to_a

    first.update!(state: 'assigned')
    event.update!(state: 'closed')

    expect(first.reload.state).to eq 'attended'
    expect(second.reload.state).to eq 'applied'
  end

  it 'updates attended participations to assigned when course state changes from closed' do
    first, second = subject.participations.joins(:roles).
      where(event_roles: { type: Event::Course::Role::Participant.sti_name }).to_a

    first.update!(state: 'assigned')
    event.update!(state: 'closed')

    expect(first.reload.state).to eq 'attended'
    expect(second.reload.state).to eq 'applied'

    event.update!(state: 'application_open')

    expect(first.reload.state).to eq 'assigned'
    expect(second.reload.state).to eq 'applied'
  end

end
