# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::RolesController do

  let(:group) { course.groups.first }
  let(:course) { events(:top_course) }

  before { sign_in(people(:top_leader)) }

  context 'POST create' do

    it 'creates helper in state assigned' do
      expect do
        post :create,
             params: {
               group_id: group.id,
               event_id: course.id,
               event_role: {
                 type: Event::Role::Cook.sti_name,
                 person_id: people(:bottom_leader).id
               }
             }
      end.to change { Event::Participation.count }.by(1)

      role = assigns(:role)
      expect(role).to be_persisted
      expect(role.participation.state).to eq 'assigned'
      expect(course.reload.applicant_count).to eq 1
      expect(course.teamer_count).to eq 2
      expect(course.participant_count).to eq 1
    end


    it 'sets event_participation state to applied if tentative participation exists' do
      Fabricate(:event_participation, 
                event: course, 
                participant: people(:bottom_leader),
                active: false, 
                state: 'tentative')

      expect do
        post :create,
             params: {
               group_id: group.id,
               event_id: course.id,
               event_role: {
                 type: Event::Role::Cook.sti_name,
                 person_id: people(:bottom_leader).id
               }
             }
      end.not_to change(Event::Participation, :count)

      role = assigns(:role)
      expect(role).to be_persisted
      expect(role.participation.state).to eq 'assigned'
    end

  end

end
