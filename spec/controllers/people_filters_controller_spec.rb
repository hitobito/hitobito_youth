# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe PeopleFiltersController do

  before { sign_in(people(:top_leader)) }
  let(:group) { groups(:top_group) }

  context 'GET#new' do
    render_views
    let(:dom) { Capybara::Node::Simple.new(response.body) }

    it 'sets education value to true if education param present' do
      get :new, params: { group_id: group.id, education: 'true' }
      expect(dom).to have_selector('input[name="education"]', visible: false)
      expect(dom.find('input[name="education"]', visible: false).value).to eq 'true'
    end

    it 'sets education value to nil if education param missing' do
      get :new, params: { group_id: group.id }
      expect(dom).not_to have_selector('input[name="education"]')
    end
  end

  context 'POST#create' do
    it 'with education redirects to education' do
      post :create, params: { group_id: group.id, education: 'true', people_filter: { name: 'test' } }
      is_expected.to redirect_to educations_path(group)
    end

    it 'without education redirects to group_people' do
      post :create, params: { group_id: group.id, people_filter: { name: 'test' } }
      is_expected.to redirect_to group_people_path(group)
    end

    it 'with education false redirects to group_people' do
      post :create, params: { group_id: group.id, people_filter: { name: 'test' }, education: 'false' }
      is_expected.to redirect_to group_people_path(group)
    end
  end

  context 'DELETE#destroy' do
    let!(:filter) { PeopleFilter.create!(name: 'test', group: group) }

    it 'without education redirects to group_people' do
      delete :destroy, params: { group_id: group.id, id: filter.id }
      is_expected.to redirect_to group_people_path(group)
    end

    it 'with education = false redirects to group_people' do
      delete :destroy, params: { group_id: group.id, id: filter.id, education: 'false' }
      is_expected.to redirect_to group_people_path(group)
    end

    it 'with education redirects to education' do
      delete :destroy, params: { group_id: group.id, id: filter.id, education: 'true' }
      is_expected.to redirect_to educations_path(group)
    end
  end

end
