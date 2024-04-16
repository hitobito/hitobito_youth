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

  def can?(*_args)
    true
  end

  def top_menu_entries(dropdown)
    menu = dropdown.find('.btn-group > ul.dropdown-menu')
    menu.all('> li > a').map(&:text)
  end

  def submenu_entries(dropdown, name)
    menu = dropdown.find('.btn-group > ul.dropdown-menu')
    menu.all("> li > a:contains('#{name}') ~ ul > li > a").map(&:text)
  end

  it 'renders dropdown' do
    dropdown = create_dropdown
    expect(dropdown).to have_content 'Export'
    expect(dropdown).to have_selector '.btn-group > ul.dropdown-menu'

    expect(top_menu_entries(dropdown)).to match_array %w(CSV Excel vCard PDF)

    expect(submenu_entries(dropdown, 'CSV')).to match_array %w(Spaltenauswahl Adressliste)
  end

  context 'nds' do

    it 'no nds items if no details permission' do
      dropdown = create_dropdown
      subitems = submenu_entries(dropdown, 'CSV')
      expect(subitems).not_to include 'NDS-Kurs'
      expect(subitems).not_to include 'NDS-Lager'
      expect(subitems).not_to include 'SLRG-Kurs'
    end

    it 'no nds items if not people controller' do
      dropdown = create_dropdown(true, 'people')
      subitems = submenu_entries(dropdown, 'CSV')
      expect(subitems).not_to include 'NDS-Kurs'
      expect(subitems).not_to include 'NDS-Lager'
      expect(subitems).not_to include 'SLRG-Kurs'
    end

    it 'does add nds items' do
      dropdown = create_dropdown(true)
      subitems = submenu_entries(dropdown, 'CSV')
      expect(subitems).to include 'NDS-Kurs'
      expect(subitems).to include 'NDS-Lager'
      expect(subitems).to include 'SLRG-Kurs'
    end
  end

  context 'subclass can override' do
    def define_subclass(&block)
      subclass = Class.new(Dropdown::PeopleExport, &block)
      # Replace the original class with the subclass instead of using it directly,
      # so I18n will find the original translations.
      stub_const('Dropdown::PeopleExport', subclass)
    end

    it 'if wagon claims it is a camp adds correct NDS items' do
      define_subclass do
        def is_camp?(*) = true
        def is_course?(*) = false
      end

      subitems = submenu_entries(create_dropdown(true), 'CSV')
      expect(subitems).not_to include 'NDS-Kurs'
      expect(subitems).to include 'NDS-Lager'
      expect(subitems).not_to include 'SLRG-Kurs'
    end

    it 'if wagon claims it is a course adds correct NDS items' do
      define_subclass do
        def is_camp?(*) = false
        def is_course?(*) = true
      end

      subitems = submenu_entries(create_dropdown(true), 'CSV')
      expect(subitems).to include 'NDS-Kurs'
      expect(subitems).not_to include 'NDS-Lager'
      expect(subitems).to include 'SLRG-Kurs'
    end

    it '#tabular_links can add subitem' do
      define_subclass do
        def tabular_links(format)
          super.tap do |item|
            item.sub_items <<
              Dropdown::Item.new('Hello World', '/hello-world', data: { checkable: true })
          end
        end
      end

      dropdown = create_dropdown
      expect(top_menu_entries(dropdown)).to match_array %w(CSV Excel vCard PDF)
      expect(submenu_entries(dropdown,
                             'CSV')).to match_array ['Spaltenauswahl', 'Adressliste', 'Hello World']
    end
  end

  private

  def create_dropdown(details = false, controller = 'event/participations')
    html = Dropdown::PeopleExport.new(self,
                                      user,
                                      { controller: controller,
                                        group_id: groups(:top_group).id,
                                        event_id: events(:top_course).id },
                                      { details: details }).to_s
    Capybara.string(html)
  end
end
