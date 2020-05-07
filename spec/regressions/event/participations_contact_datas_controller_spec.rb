# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# encoding:  utf-8

require 'spec_helper'

describe Event::ParticipationContactDatasController, type: :controller do

  render_views

  let(:group) { groups(:top_layer) }
  let(:course) { Fabricate(:course, groups: [group]) }
  let(:person) { people(:top_leader) }
  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(person) }

  describe 'GET edit' do

    it 'does not show hidden contact fields' do

      course.update!({ hidden_contact_attrs: ['ahv_number'] })

      get :edit, params: { group_id: course.groups.first.id, event_id: course.id, event_role: { type: 'Event::Course::Role::Participant' } }

      expect(dom).to have_selector('input#event_participation_contact_data_j_s_number')
      expect(dom).to have_selector('select#event_participation_contact_data_nationality_j_s')

      expect(dom).to have_no_selector('input#event_participation_contact_data_ahv_number')

    end

    it 'shows all contact fields by default' do

      get :edit, params: { group_id: course.groups.first.id, event_id: course.id, event_role: { type: 'Event::Course::Role::Participant' } }

      expect(dom).to have_selector('input#event_participation_contact_data_j_s_number')
      expect(dom).to have_selector('input#event_participation_contact_data_ahv_number')
      expect(dom).to have_selector('select#event_participation_contact_data_nationality_j_s')

    end

  end

  context 'POST update' do

    before do
      course.update!({ required_contact_attrs: ['j_s_number']})
    end

    it 'validates contact attributes and person attributes' do

      contact_data_params = { first_name: 'Hans', last_name: 'Gugger',
                              email: 'hans@youth.com', nickname: 'dude',
                              j_s_number: '' }

      post :update, params: { group_id: group.id, event_id: course.id, event_participation_contact_data: contact_data_params, event_role: { type: 'Event::Course::Role::Participant' } }

      is_expected.to render_template(:edit)

      expect(dom).to have_selector('.alert-error li', text: 'J+S-Nummer muss ausgefüllt werden')

    end

    it 'updates person attributes and redirects to event questions' do

      contact_data_params = { first_name: 'Hans', last_name: 'Gugger',
                              email: 'hans@youth.com', nickname: 'dude',
                              j_s_number: '4242' }

      post :update, params: { group_id: group.id, event_id: course.id, event_participation_contact_data: contact_data_params, event_role: { type: 'Event::Course::Role::Participant' } }

      is_expected.to redirect_to new_group_event_participation_path(group,
                                                                    course,
                                                                    event_role: { type: 'Event::Course::Role::Participant' })

      person.reload
      expect(person.j_s_number).to eq('4242')

    end
  end

end
