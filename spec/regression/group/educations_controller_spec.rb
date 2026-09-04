# encoding: utf-8

#  Copyright (c) 2012-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Group::EducationsController, type: :controller do

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
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.type_id } } }
    expect(response.body).to have_content 'Leader Top'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does list participant participations' do
    get :index, params: { id: groups(:bottom_layer_one).id }
    expect(response.body).to have_content 'Member Bottom'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does not list completed events' do
    events(:top_course).dates.last.update!(start_at: Date.today - 1.month)
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.type_id } } }
    expect(response.body).not_to have_content 'Top Course'
  end

  it 'lists qualifications' do
    create_qualification(start_at: Date.yesterday)
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.type_id } } }
    expect(response.body).to have_content 'Super Lead'
  end

  it 'lists qualifications event when expired' do
    create_qualification(start_at: Date.today - 3.days, finish_at: Date.yesterday)
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.type_id } } }
    expect(response.body).to have_content 'Super Lead'
  end

  it 'filters qualifications positive' do
    create_qualification(start_at: Date.yesterday)
    get :index,
        params: {
          id: groups(:top_layer).id,
          range: :layer,
          filters: { qualification: { qualification_kind_ids: qualification_kinds(:sl).id } }
        }
    expect(response.body).to have_content 'Super Lead'
  end

  it 'filters qualifications negative' do
    create_qualification(start_at: Date.yesterday)
    get :index,
        params: {
          id: groups(:top_layer).id,
          range: :layer,
          filters: { qualification: { qualification_kind_ids: qualification_kinds(:gl).id } }
        }
    expect(response.body).not_to have_content 'Super Lead'
  end

  it 'raises AccessDenied if not permitted' do
    sign_in(people(:bottom_leader))
    expect do
      get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.type_id } } }
    end.to raise_error CanCan::AccessDenied
  end

  describe 'sorting' do
    let(:group) { groups(:bottom_layer_one) }

    # kind sl has a validity of two, kind gl of one year.

    let!(:alice) do # expires end of next year
      create_member('Anderegg', 'Alice', Date.new(1990, 3, 1)).tap do |p|
        create_qualification_for(p, :sl, 1.year.ago.to_date)
        # of the same kind, only the one expiring last counts
        create_qualification_for(p, :sl, 2.years.ago.to_date)
      end
    end

    let!(:bruno) do # expires end of this year
      create_member('Berger', 'Bruno', Date.new(1980, 6, 15)).tap do |p|
        create_qualification_for(p, :sl, Time.zone.today)
        create_qualification_for(p, :gl, 1.year.ago.to_date)
      end
    end

    let!(:carla) do # expires end of next year
      create_member('Corti', 'Carla', Date.new(1990, 3, 1)).tap do |p|
        create_qualification_for(p, :sl, 1.year.ago.to_date)
        # already expired and thus not shown
        create_qualification_for(p, :gl, 3.years.ago.to_date)
      end
    end

    def create_member(last_name, first_name, birthday)
      Fabricate(Group::BottomLayer::Member.name.to_sym, group: group).person.tap do |p|
        p.update!(last_name: last_name, first_name: first_name, birthday: birthday)
      end
    end

    def create_qualification_for(person, kind, start_at)
      Qualification.create!(person: person,
                            qualification_kind: qualification_kinds(kind),
                            start_at: start_at)
    end

    def sorted_ids(params = {})
      get :index, params: { id: group.id }.merge(params)
      assigns(:people).collect(&:id) & [alice.id, bruno.id, carla.id]
    end

    it 'sorts by person name by default' do
      expect(sorted_ids).to eq [alice.id, bruno.id, carla.id]
    end

    it 'sorts by person name descending' do
      expect(sorted_ids(sort: :name, sort_dir: :desc)).to eq [carla.id, bruno.id, alice.id]
    end

    it 'sorts by the first expiring qualification kind, then by person name' do
      expect(sorted_ids(sort: :qualification, sort_dir: :asc)).to eq [bruno.id, alice.id, carla.id]
    end

    it 'sorts never expiring qualifications last' do
      dora = create_member('Durrer', 'Dora', Date.new(1990, 3, 1))
      Qualification.create!(person: dora, start_at: 1.year.ago.to_date,
                            qualification_kind: Fabricate(:qualification_kind, validity: nil))
      # no quali at all
      elodie = create_member('Eberhard', 'Elodie', Date.new(1985, 6, 15))
      get :index, params: { id: group.id, sort: :qualification, sort_dir: :asc }
      ids = assigns(:people).collect(&:id) & [alice.id, bruno.id, carla.id, dora.id, elodie.id]
      expect(ids).to eq [bruno.id, alice.id, carla.id, dora.id, elodie.id]
    end

    it 'sorts all people below a group by qualification descending' do
      get :index, params: { id: groups(:top_layer).id, range: :deep,
                            sort: :qualification, sort_dir: :desc }
      ids = assigns(:people).collect(&:id) & [alice.id, bruno.id, carla.id]
      # the second order criteria follows the sort direction of the first one
      expect(ids).to eq [carla.id, alice.id, bruno.id]
    end

    it 'sorts by birthday, then by person name' do
      expect(sorted_ids(sort: :birthday, sort_dir: :asc)).to eq [bruno.id, alice.id, carla.id]
    end

    it 'renders sort links for the sortable columns' do
      get :index, params: { id: group.id }
      expect(response.body).to have_css("th a[href*='sort=name']")
      expect(response.body).to have_css("th a[href*='sort=qualification']")
      expect(response.body).to have_css("th a[href*='sort=birthday']")
    end
  end

end
