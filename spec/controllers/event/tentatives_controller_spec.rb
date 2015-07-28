# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::TentativesController do

  let(:group) { groups(:bottom_layer_one) }
  let(:course) { Fabricate(:youth_course, groups: [group], tentative_applications: true) }

  before { sign_in(people(:top_leader)) }

  context 'GET#index' do
    def create_participation(role, group, state)
      person = Fabricate(role.name, group: group).person
      Fabricate(:youth_participation, event: course, person: person, state: state)
    end

    def fetch_count(name)
      assigns(:counts).fetch([groups(name).id, groups(name).name])
    end

    it 'counts tentative applications grouped by layer_group' do
      create_participation(Group::BottomLayer::Member, groups(:bottom_layer_one), 'tentative')
      create_participation(Group::BottomGroup::Member, groups(:bottom_group_one_one), 'tentative')
      create_participation(Group::BottomGroup::Member, groups(:bottom_group_one_two), 'tentative')
      create_participation(Group::BottomGroup::Member, groups(:bottom_group_one_two), 'assigned')

      create_participation(Group::BottomLayer::LocalGuide, groups(:bottom_layer_two), 'tentative')

      get :index, group_id: course.groups.first.id, event_id: course.id

      expect(assigns(:counts)).to have(2).items
      expect(fetch_count(:bottom_layer_one)).to eq 3
      expect(fetch_count(:bottom_layer_two)).to eq 1
    end


    it 'raises AccessDenied if not permitted to list_tentatives on event' do
      sign_in(people(:bottom_leader))
      course = Fabricate(:youth_course, groups: [groups(:top_layer)], tentative_applications: true)
      expect do
        get :index, group_id: course.groups.first.id, event_id: course.id
      end.to raise_error CanCan::AccessDenied
    end
  end

  context 'POST#create' do
    let(:participation) { assigns(:participation) }

    it 'raises CanCan::AccessDenied when course does not support tentative applications' do
      course.update!(tentative_applications: false)
      expect do
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: people(:bottom_leader).id }
      end.to raise_error CanCan::AccessDenied
    end

    it 'raises CanCan::AccessDenied when person is not accessible' do
      participant = Fabricate(Group::BottomGroup::Member.name, group: groups(:bottom_group_one_one)).person
      expect do
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: participant.id }
      end.to raise_error CanCan::AccessDenied
    end

    it 'sets participation state to tentative' do
      expect do
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: people(:bottom_leader).id }
      end.not_to change { Delayed::Job.count }

      expect(participation.state).to eq 'tentative'
      expect(participation.active).to eq(false)
      expect(participation.application).to be_nil
      expect(participation.roles).to have(1).item
      expect(participation.roles.first.class).to eq Event::Course::Role::Participant
    end

  end

  context 'GET#query' do
    let(:json) { JSON.parse(response.body) }

    it "returns people as typeahead" do
      sign_in(people(:bottom_leader))

      get :query, group_id: group.id, event_id: course.id, q: 'Bottom', format: :js
      expect(json).to have(2).item
      expect(json.first['label']).to eq 'Bottom Leader, Greattown'
      expect(json.second['label']).to eq 'Bottom Member, Greattown'
    end

    it "only finds people for which user may update" do
      p = Fabricate(Group::BottomGroup::Member.name, group: groups(:bottom_group_one_one)).person
      sign_in(people(:top_leader))

      get :query, group_id: group.id, event_id: course.id, q: p.first_name, format: :js
      expect(json).to be_empty
    end
  end

end
