# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::ParticipationsController do

  let(:group) { course.groups.first }
  let(:course) { Fabricate(:youth_course, groups: [groups(:top_layer)]) }
  let(:participation) { assigns(:participation).reload }

  before { sign_in(people(:top_leader)) }


  context 'GET#index' do
    it 'does not include tentative participants' do
      Fabricate(:event_participation,
                event: course,
                state: 'applied',
                person: people(:bottom_member),
                active: true)
      get :index, group_id: group.id, event_id: course.id
      expect(assigns(:participations)).to be_empty
    end

    it 'exports csv files' do
      expect do
        get :index, group_id: group, event_id: course.id, format: :csv
        expect(flash[:notice]).to match(/Export wird im Hintergrund gestartet und nach Fertigstellung heruntergeladen./)
      end.to change(Delayed::Job, :count).by(1)
    end
  end

  context 'POST#create' do

    it 'sets participation state to applied' do
      post :create,
           group_id: group.id,
           event_id: course.id,
           event_participation: { person_id: people(:top_leader).id }
      expect(participation.state).to eq 'applied'

      expect(course.reload.applicant_count).to eq 1
      expect(course.teamer_count).to eq 0
      expect(course.participant_count).to eq 0
    end

    it 'sets participation state to assigned when created by organisator' do
      post :create,
           group_id: group.id,
           event_id: course.id,
           event_participation: { person_id: people(:bottom_member).id }
      expect(participation.state).to eq 'assigned'

      expect(course.reload.applicant_count).to eq 1
      expect(course.teamer_count).to eq 0
      expect(course.participant_count).to eq 1
    end

  end


  context 'state changes' do
    let(:participation) { Fabricate(:youth_participation, event: course) }

    context 'PUT cancel' do

      it 'cancels participation' do
        put :cancel,
             group_id: group.id,
             event_id: course.id,
             id: participation.id,
             event_participation: { canceled_at: Date.today }
        expect(flash[:notice]).to be_present
        participation.reload
        expect(participation.canceled_at).to eq Date.today
        expect(participation.state).to eq 'canceled'
        expect(participation.active).to eq false

        expect(course.reload.applicant_count).to eq 0
        expect(course.teamer_count).to eq 0
        expect(course.participant_count).to eq 0
      end

      it 'requires canceled_at date' do
        put :cancel,
             group_id: group.id,
             event_id: course.id,
             id: participation.id,
             event_participation: { canceled_at: ' ' }
        expect(flash[:alert]).to be_present
        participation.reload
        expect(participation.canceled_at).to eq nil
      end
    end

    context 'PUT reject' do
      render_views
      let(:dom) { Capybara::Node::Simple.new(response.body) }

      it 'rejects participation' do
        put :reject,
          group_id: group.id,
          event_id: course.id,
          id: participation.id
        participation.reload
        expect(participation.state).to eq 'rejected'
        expect(participation.active).to eq false
      end
    end

    it 'PUT attend sets participation state to attended' do
      put :attend,
        group_id: group.id,
        event_id: course.id,
        id: participation.id
      participation.reload
      expect(participation.active).to be true
      expect(participation.state).to eq 'attended'
    end

    it 'PUT absent sets participation state to abset' do
      put :absent,
        group_id: group.id,
        event_id: course.id,
        id: participation.id
      participation.reload
      expect(participation.active).to be false
      expect(participation.state).to eq 'absent'
    end

    it 'PUT assign sets participation state to abset' do
      put :assign,
        group_id: group.id,
        event_id: course.id,
        id: participation.id
      participation.reload
      expect(participation.active).to be true
      expect(participation.state).to eq 'assigned'
    end
  end
end
