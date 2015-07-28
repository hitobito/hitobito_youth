# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationAbility do

  def build(attrs)
    course = Event::Course.new(groups: attrs.fetch(:groups).map { |g| groups(g) }, tentative_applications: true)
    @participation = Event::Participation.new(event: course, person: attrs[:person])
  end

  let(:participation) { @participation }

  context 'participation without person' do
    subject { Ability.new(Fabricate(Group::BottomLayer::Leader.name.to_sym, group: groups(:bottom_layer_one)).person) }

    it 'may create_tentative for event higher up in organisation' do
      is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer]))
    end

    it 'may create_tentative for event further down in organisation' do
      is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one]))
    end

    it 'may not create_tentative for event in different branch and higher layer of organisation' do
      is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_two]))
    end

    it 'may create_tentative for event if one of the groups is permitted' do
      is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one, :bottom_layer_two]))
    end
  end

  context 'participation with person' do

    context 'layer_and_below_full' do
      subject { Ability.new(Fabricate(Group::BottomLayer::Leader.name, group: groups(:bottom_layer_one)).person) }

      it 'may not create_tentative for person in upper layer' do
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: people(:top_leader)))
      end

      it 'may create_tentative for person in his group' do
        person = Fabricate(Group::BottomLayer::Member.name, group: groups(:bottom_layer_one)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
      end

      it 'may not create_tentative for person in different group on same layer' do
        person = Fabricate(Group::BottomLayer::Member.name, group: groups(:bottom_layer_two)).person
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
      end

      it 'may create_tentative for person in layer below' do
        person = Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
      end
    end

    context 'layer_full' do
      context 'in top layer' do
        subject { Ability.new(Fabricate(Group::TopGroup::LocalGuide.name, group: groups(:top_group)).person) }

        it 'may create_tentative for person in same layer' do
          is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: people(:top_leader)))
        end

        it 'may create_tentative for person in his group' do
          person = Fabricate(Group::TopGroup::Member.name, group: groups(:top_group)).person
          is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
        end

        it 'may not create_tentative for person in layer below' do
          person = Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person
          is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
        end
      end

      context 'in bottom layer' do
        subject { Ability.new(Fabricate(Group::BottomLayer::LocalGuide.name, group: groups(:bottom_layer_one)).person) }

        it 'may not create_tentative for person in upper layer' do
          is_expected.not_to be_able_to(:create_tentative, build(groups: [:top_layer], person: people(:top_leader)))
        end

        it 'may create_tentative for person in his group' do
          person = Fabricate(Group::BottomLayer::Member.name, group: groups(:bottom_layer_one)).person
          is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
        end

        it 'may create_tentative for person in group below' do
          person = Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person
          is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
        end
      end
    end

    context 'group_full' do
      subject { Ability.new(Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person) }

      it 'may not create_tentative for person in upper layer' do
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: people(:top_leader)))
      end

      it 'may create_tentative for person in his group' do
        person = Fabricate(Group::BottomGroup::Member.name, group: groups(:bottom_group_one_one)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
      end
    end
  end
end
