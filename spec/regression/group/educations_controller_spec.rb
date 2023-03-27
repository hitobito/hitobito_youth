# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
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
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
    expect(response.body).to have_content 'Top Leader'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does list participant participations' do
    get :index, params: { id: groups(:bottom_layer_one).id }
    expect(response.body).to have_content 'Member Bottom'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does not list completed events' do
    events(:top_course).dates.last.update!(start_at: Date.today - 1.month)
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
    expect(response.body).not_to have_content 'Top Course'
  end

  it 'lists qualifications' do
    create_qualification(start_at: Date.yesterday)
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
    expect(response.body).to have_content 'Super Lead'
  end

  it 'lists qualifications event when expired' do
    create_qualification(start_at: Date.today - 3.days, finish_at: Date.yesterday)
    get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
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
      get :index, params: { id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
    end.to raise_error CanCan::AccessDenied
  end

  context 'exports to csv' do
    let(:rows) { response.body.split("\n") }
    it 'CSV does list leader participations' do
      get :index, params: { locale: :de, id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } }, format: :csv }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.size).to eq(2)
      expect(rows.second).to have_content 'Top;Leader'
      expect(rows.second).to have_content 'Top Course'
    end

    it 'CSV does list participant participations' do
      get :index, params: { locale: :de, format: :csv, id: groups(:bottom_layer_one).id }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.size).to eq(3)
      expect(rows.third).to have_content 'Bottom;Member;'
      expect(rows.third).to have_content 'Top Course'
    end

    it 'CSV does not list completed events' do
      events(:top_course).dates.last.update!(start_at: Date.today - 1.month)
      get :index, params: { locale: :de, format: :csv, id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.second).to eq("Top;Leader;;top_leader@example.com;;\"\";\"\"")
    end

    it 'CSV lists qualifications' do
      create_qualification(start_at: Date.yesterday)
      get :index, params: { locale: :de, format: :csv, id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.second).to have_content 'Super Lead'
    end

    it 'CSV lists qualifications event when expired' do
      create_qualification(start_at: Date.today - 3.days, finish_at: Date.yesterday)
      get :index, params: { locale: :de, format: :csv, id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.second).to have_content 'Super Lead'
    end

    it 'CSV filters qualifications positive' do
      create_qualification(start_at: Date.yesterday)
      get :index,
          params: {
            locale: :de,
            format: :csv,
            id: groups(:top_layer).id,
            range: :layer,
            filters: { qualification: { qualification_kind_ids: qualification_kinds(:sl).id } }
          }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.second).to have_content 'Super Lead'
    end

    it 'CSV filters qualifications negative' do
      create_qualification(start_at: Date.yesterday)
      get :index,
          params: {
            locale: :de,
            format: :csv,
            id: groups(:top_layer).id,
            range: :layer,
            filters: { qualification: { qualification_kind_ids: qualification_kinds(:gl).id } }
          }
      expect(response).to be_successful
      expect(rows.first).to match("Vorname;Nachname;Übername;Haupt-E-Mail;Geburtstag;Qualifikationen;Anmeldungen")
      expect(rows.second).not_to have_content 'Super Lead'
    end

    it 'CSV raises AccessDenied if not permitted' do
      sign_in(people(:bottom_leader))
      expect do
        get :index, params: { locale: :de, format: :csv, id: groups(:top_layer).id, range: :layer, filters: { role: { role_type_ids: Group::TopGroup::Leader.id } } }
      end.to raise_error CanCan::AccessDenied
    end
  end

end
