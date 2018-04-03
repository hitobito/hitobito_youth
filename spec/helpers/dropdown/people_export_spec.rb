# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe 'Dropdown::PeopleExport' do

  include FormatHelper
  include LayoutHelper
  include UtilityHelper

  let(:user) { people(:top_leader) }
  let(:params) { { controller: 'event/participations' } }

  def can?(*args)
    true
  end

  context 'ndbjs' do

    it 'no ndbjs items if no details permission' do
      dropdown = create_dropdown.to_s
      expect(dropdown).to have_content 'Export'
      expect(dropdown).to have_selector 'a' do |tag|
        expect(tag).to have_content 'CSV'
        expect(tag).not_to have_selector 'ul.dropdown-submenu'
        expect(tag).to_not have_content 'NDBJS'
        expect(tag).to_not have_content 'SPORTdb'
      end
    end

    it 'no ndbjs items if not people controller' do
      dropdown = create_dropdown(true, 'people').to_s
      expect(dropdown).to have_content 'Export'
      expect(dropdown).to have_selector 'a' do |tag|
        expect(tag).to have_content 'CSV'
        expect(tag).not_to have_selector 'ul.dropdown-submenu'
        expect(tag).to_not have_content 'NDBJS'
        expect(tag).to_not have_content 'SPORTdb'
      end
    end

    it 'does add ndbjs items' do
      dropdown = create_dropdown(true).to_s
      expect(dropdown).to have_content 'Export'
      expect(dropdown).to have_selector 'ul.dropdown-menu'
      expect(dropdown).to have_selector 'a' do |tag|
        expect(tag).to have_content 'CSV'
        expect(tag).to have_selector 'ul.dropdown-submenu'
        expect(tag).to have_content 'NDBJS'
        expect(tag).to have_content 'SPORTdb'
      end
    end
  end

  private
  def create_dropdown(details = false, controller = 'event/participations')
    Dropdown::PeopleExport.new(self,
                               user,
                               { controller: controller,
                                 group_id: groups(:top_group).id,
                                 event_id: events(:top_course).id
                                },
                                { details: details })
  end
end
