# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Group::EducationsController do

  render_views

  let(:person) { people(:top_leader) }

  before { sign_in(person) }
  before do
    events(:top_course).dates.last.update!(start_at: Date.today + 1.month)
  end

  def create_qualification(attrs)
    Qualification.create!(attrs.merge(qualification_kind: qualification_kinds(:sl), person: person))
  end

  it 'does list leader participations' do
    get :index, id: groups(:top_layer).id, kind: :layer, role_type_ids: Group::TopGroup::Leader.id
    expect(response.body).to have_content 'Top Leader'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does list participant participations' do
    get :index, id: groups(:bottom_layer_one).id
    expect(response.body).to have_content 'Member Bottom'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does not list completed events' do
    events(:top_course).dates.last.update!(start_at: Date.today - 1.month)
    get :index, id: groups(:top_layer).id, kind: :layer, role_type_ids: Group::TopGroup::Leader.id
    expect(response.body).not_to have_content 'Top Course'
  end

  it 'lists qualifications' do
    create_qualification(start_at: Date.yesterday)
    get :index, id: groups(:top_layer).id, kind: :layer, role_type_ids: Group::TopGroup::Leader.id
    expect(response.body).to have_content 'Super Lead'
  end

  it 'lists qualifications event when expired' do
    create_qualification(start_at: Date.today - 3.days, finish_at: Date.yesterday)
    get :index, id: groups(:top_layer).id, kind: :layer, role_type_ids: Group::TopGroup::Leader.id
    expect(response.body).to have_content 'Super Lead'
  end

  it 'raises AccessDenied if not permitted' do
    sign_in(people(:bottom_leader))
    expect do
      get :index, id: groups(:top_layer).id, kind: :layer, role_type_ids: Group::TopGroup::Leader.id
    end.to raise_error CanCan::AccessDenied
  end

end
