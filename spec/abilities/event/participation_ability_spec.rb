# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::ParticipationAbility do

  def build(attrs)
    course = Event::Course.new(groups: attrs.fetch(:groups).map { |g| groups(g) }, tentative_applications: true)
    @participation = Event::Participation.new(event: course, person: attrs[:person])
  end

  let(:participation) { @participation }
  let(:user) { role.person }
  let(:writables) { Person.accessible_by(PersonLayerWritables.new(user)) }

  subject { Ability.new(user) }

  context 'participation without person' do
    let(:role) { Fabricate(Group::BottomLayer::Leader.name.to_sym, group: groups(:bottom_layer_one)) }

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
      let(:role) { Fabricate(Group::BottomLayer::Leader.name, group: groups(:bottom_layer_one)) }

      it 'may not create_tentative for person in upper layer' do
        person = people(:top_leader)
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
        expect(writables).not_to include(person)
      end

      it 'may create_tentative for person in his group' do
        person = Fabricate(Group::BottomLayer::Member.name, group: groups(:bottom_layer_one)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
        expect(writables).to include(person)
      end

      it 'may not create_tentative for person in different layer' do
        person = Fabricate(Group::BottomLayer::Member.name, group: groups(:bottom_layer_two)).person
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
        expect(writables).not_to include(person)
      end

      it 'may create_tentative for person in layer below' do
        person = Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
        expect(writables).to include(person)
      end
    end

    context 'layer_full' do
      context 'in top layer' do
        let(:role) { Fabricate(Group::TopGroup::LocalGuide.name, group: groups(:top_group)) }

        it 'may create_tentative for person in same layer' do
          person = people(:top_leader)
          is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
          expect(writables).to include(person)
        end

        it 'may create_tentative for person in his group' do
          person = Fabricate(Group::TopGroup::Member.name, group: groups(:top_group)).person
          is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
          expect(writables).to include(person)
        end

        it 'may not create_tentative for person in layer below' do
          person = Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person
          is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
          expect(writables).not_to include(person)
        end
      end

      context 'in bottom layer' do
        let(:role) { Fabricate(Group::BottomLayer::LocalGuide.name, group: groups(:bottom_layer_one)) }

        it 'may not create_tentative for person in upper layer' do
          person = people(:top_leader)
          is_expected.not_to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
          expect(writables).not_to include(person)
        end

        it 'may create_tentative for person in his group' do
          person = Fabricate(Group::BottomLayer::Member.name, group: groups(:bottom_layer_one)).person
          is_expected.to be_able_to(:create_tentative, build(groups: [:top_layer], person: person))
          expect(writables).to include(person)
        end

        it 'may create_tentative for person in group below' do
          person = Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)).person
          is_expected.to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
          expect(writables).to include(person)
        end
      end
    end

    context 'group_full' do
      let(:role) { Fabricate(Group::BottomGroup::Leader.name, group: groups(:bottom_group_one_one)) }

      it 'may not create_tentative for person in upper layer' do
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: people(:top_leader)))
      end

      it 'may not create_tentative for person in his group' do
        person = Fabricate(Group::BottomGroup::Member.name, group: groups(:bottom_group_one_one)).person
        expect(writables).not_to include(person)
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:bottom_layer_one], person: person))
      end
    end
  end

  context 'manager inherited permissions' do

    let(:participant) { Fabricate(:person) }
    let(:manager) { Fabricate(:person) }
    let!(:manager_relation) { PeopleManager.create(manager: manager, managed: participant) }

    let(:course)   { Fabricate(:course) }
    let(:participation) { Fabricate(:event_participation, event: course, person: participant) }

    subject { Ability.new(user) }

    context 'for self' do
      let(:user) { participant }

      context 'if event applications are not possible / cancelable' do
        it { is_expected.to be_able_to :show, participation }
        it { is_expected.to be_able_to :show_details, participation }
        it { is_expected.not_to be_able_to :create, participation }
        it { is_expected.not_to be_able_to :destroy, participation }
      end

      context 'if event application is possible / cancelable' do
        before { course.update(state: :application_open, applications_cancelable: true) }
        it { is_expected.to be_able_to :show, participation }
        it { is_expected.to be_able_to :show_details, participation }
        it { is_expected.to be_able_to :create, participation }
        it { is_expected.to be_able_to :destroy, participation }

        context 'but event is in archived group' do
          before { course.groups.each(&:archive!) }
          it { is_expected.not_to be_able_to :create, participation }
        end
      end

      context 'as event leader' do
        let!(:leader_role) { Fabricate(Event::Role::Leader.name, participation: participation) }
        let(:other_participation) { Fabricate(:event_participation, event: course) }
        it { is_expected.to be_able_to :show, other_participation }
        it { is_expected.to be_able_to :show_details, other_participation }
      end
    end

    context 'for manager' do
      let(:user) { manager }

      context 'if event applications are not possible / cancelable' do
        it { is_expected.to be_able_to :show, participation }
        it { is_expected.to be_able_to :show_details, participation }
        it { is_expected.not_to be_able_to :create, participation }
        it { is_expected.not_to be_able_to :destroy, participation }
      end

      context 'if event application is possible / cancelable' do
        before { course.update(state: :application_open, applications_cancelable: true) }
        it { is_expected.to be_able_to :show, participation }
        it { is_expected.to be_able_to :show_details, participation }
        it { is_expected.to be_able_to :create, participation }
        it { is_expected.to be_able_to :destroy, participation }

        context 'but event is in archived group' do
          before { course.groups.each(&:archive!) }
          it { is_expected.not_to be_able_to :create, participation }
        end

        context 'of event leader' do
          let!(:leader_role) { Fabricate(Event::Role::Leader.name, participation: participation) }
          let(:other_participation) { Fabricate(:event_participation, event: course) }
          it 'does not inherit show permissions on participants' do
            is_expected.not_to be_able_to :show, other_participation
          end
          it 'does not inherit show_details permissions on participants' do
            is_expected.not_to be_able_to :show_details, other_participation
          end
        end
      end
    end

    context 'for unrelated user' do
      let(:user) { Fabricate(:person) }
      context 'if event applications are not possible / cancelable' do
        it { is_expected.not_to be_able_to :show, participation }
        it { is_expected.not_to be_able_to :show_details, participation }
        it { is_expected.not_to be_able_to :create, participation }
        it { is_expected.not_to be_able_to :destroy, participation }
      end

      context 'if event application is possible / cancelable' do
        before { course.update(state: :application_open, applications_cancelable: true) }
        it { is_expected.not_to be_able_to :show, participation }
        it { is_expected.not_to be_able_to :show_details, participation }
        it { is_expected.not_to be_able_to :create, participation }
        it { is_expected.not_to be_able_to :destroy, participation }

        context 'but event is in archived group' do
          before { course.groups.each(&:archive!) }
          it { is_expected.not_to be_able_to :create, participation }
        end
      end
    end

  end
end
