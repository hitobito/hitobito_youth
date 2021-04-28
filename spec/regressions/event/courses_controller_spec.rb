# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Events::CoursesController, type: :controller do

  render_views

  before do
    travel_to Time.zone.local(2010, 1, 1, 12)
    sign_in(people(:top_leader))
  end

  let(:dom) { Capybara::Node::Simple.new(response.body) }

  let(:dropdown) { dom.find('.nav .dropdown-menu') }
  let(:top_layer) { groups(:top_layer) }
  let(:top_group) { groups(:top_group) }

  context 'state filter' do
    let(:form) { dom.find('form#course-filter') }

    it 'form contains a state-dropdown' do
      get :index
      expect(form).to have_css('select#filter_state', count: 1)
      expect(form).to have_css('select#filter_state option', count: 9)
    end
  end

end
