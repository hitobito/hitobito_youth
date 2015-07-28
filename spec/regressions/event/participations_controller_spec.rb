# encoding: utf-8
#
#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::ParticipationsController, type: :controller  do

  render_views

  let(:group) { course.groups.first }
  let(:user) { people(:bottom_leader) }
  let(:participant) { people(:bottom_member) }
  let(:course) { Fabricate(:course, groups: [groups(:bottom_layer_one)], kind: event_kinds(:slk)) }
  let(:participation) {  Fabricate(:youth_participation, event: course, person: participant) }
  let(:application) { participation.create_application(priority_1: course) }
  let(:dom) { Capybara::Node::Simple.new(response.body) }

  context 'participation' do
    before { participation.update(application: application) }

    context 'show cancel button' do
      before { sign_in(user) }

      it 'is not visible when participation canceled' do
        participation.update!(state: 'canceled', canceled_at: Date.today)
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom.find('#content')).not_to have_content 'Abmelden'
      end

      it 'is not visible whem participation rejected' do
        participation.update!(state: 'rejected')
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom.find('#content')).not_to have_content 'Abmelden'
      end

      it 'is visible when participation applied' do
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom.find('#content')).to have_content 'Abmelden'
      end

      it 'is visible when participation assigned' do
        participation.update!(state: 'assigned')
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom.find('#content')).to have_content 'Abmelden'
      end
    end

    context 'action' do
      before { sign_in(user) }

      it 'rejects participation and show mailto link in flash' do
        get :reject, group_id: group.id, event_id: course.id, id: participation.id
        is_expected.to redirect_to group_event_participation_path(group, course, participation)
        expect(flash[:notice]).to match(/wurde abgelehnt/)
        # TODO check for mail_to links with email addresses
      end

    end

  end
end
