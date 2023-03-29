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
  let(:entry) { double(event: event) }
  let(:event) { events(:top_course) }

  def can?(*args)
    true
  end

  context 'nds' do

    it 'no nds items if no details permission' do
      dropdown = create_dropdown.to_s
      expect(dropdown).to have_content 'Export'
      expect(dropdown).to have_selector 'a'
      expect(dropdown).to have_content 'CSV'
      expect(dropdown).to have_selector 'ul.dropdown-menu > li.dropdown-submenu'
      expect(dropdown).not_to have_content 'NDS-Kurs'
      expect(dropdown).not_to have_content 'NDS-Lager'
      expect(dropdown).not_to have_content 'SLRG-Kurs'
    end

    it 'no nds items if not people controller' do
      dropdown = create_dropdown(true, 'people').to_s
      expect(dropdown).to have_content 'Export'
      expect(dropdown).to have_selector 'a'
      expect(dropdown).to have_content 'CSV'
      expect(dropdown).to have_selector 'ul.dropdown-menu > li.dropdown-submenu'
      expect(dropdown).not_to have_content 'NDS-Kurs'
      expect(dropdown).not_to have_content 'NDS-Lager'
      expect(dropdown).not_to have_content 'SLRG-Kurs'
    end

    it 'does add nds items' do
      dropdown = Capybara.string(create_dropdown(true).to_s)
      expect(dropdown).to have_content 'Export'
      expect(dropdown).to have_selector 'ul.dropdown-menu'
      expect(dropdown).to have_selector 'a'
      expect(dropdown).to have_content 'CSV'
      expect(dropdown).to have_selector 'ul.dropdown-menu > li.dropdown-submenu'
      expect(dropdown).to have_content 'NDS-Kurs'
      expect(dropdown).to have_content 'NDS-Lager'
      expect(dropdown).to have_content 'SLRG-Kurs'
    end

    context 'if wagon claims it is a camp' do
      it 'adds correct NDS items' do
        allow_any_instance_of(Dropdown::PeopleExport).to receive(:is_camp?).and_return(true)
        allow_any_instance_of(Dropdown::PeopleExport).to receive(:is_course?).and_return(false)
        dropdown = Capybara.string(create_dropdown(true).to_s)
        expect(dropdown).to have_content 'Export'
        expect(dropdown).to have_selector 'ul.dropdown-menu'
        expect(dropdown).to have_selector 'a'
        expect(dropdown).to have_content 'CSV'
        expect(dropdown).to have_selector 'ul.dropdown-menu > li.dropdown-submenu'
        expect(dropdown).not_to have_content 'NDS-Kurs'
        expect(dropdown).to have_content 'NDS-Lager'
        expect(dropdown).not_to have_content 'SLRG-Kurs'
      end
    end

    context 'if wagon claims it is a course' do
      it 'adds correct NDS items' do
        allow_any_instance_of(Dropdown::PeopleExport).to receive(:is_camp?).and_return(false)
        allow_any_instance_of(Dropdown::PeopleExport).to receive(:is_course?).and_return(true)
        dropdown = Capybara.string(create_dropdown(true).to_s)
        expect(dropdown).to have_content 'Export'
        expect(dropdown).to have_selector 'ul.dropdown-menu'
        expect(dropdown).to have_selector 'a'
        expect(dropdown).to have_content 'CSV'
        expect(dropdown).to have_selector 'ul.dropdown-menu > li.dropdown-submenu'
        expect(dropdown).to have_content 'NDS-Kurs'
        expect(dropdown).not_to have_content 'NDS-Lager'
        expect(dropdown).to have_content 'SLRG-Kurs'
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
