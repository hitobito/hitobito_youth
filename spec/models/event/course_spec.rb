# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

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

end
