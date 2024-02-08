# frozen_string_literal: true

#  Copyright (c) 2024-2024, Puzzle ITC. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe 'event registration', js: true do
  let(:user) { people(:bottom_leader) }
  before do
    sign_in(user)
  end

  describe 'for an Event' do
    it 'without application window is allowed' do
      event = Fabricate(:event)
      expect(event.application_opening_at).to be_nil
      expect(event.application_closing_at).to be_nil
      expect(event).to be_application_possible

      visit group_event_path(event.groups.first, event)

      expect(page).to have_css('a.btn', text: 'Anmelden', exact_text: true)
    end

    it 'with currently open application window is allowed' do
      event = Fabricate(:event, application_opening_at: 5.days.ago, application_closing_at: 5.days.from_now)
      expect(event).to be_application_possible

      visit group_event_path(event.groups.first, event)

      expect(page).to have_css('a.btn', text: 'Anmelden', exact_text: true)
    end

    it 'with application window in the future is not allowed' do
      event = Fabricate(:event, application_opening_at: 2.days.from_now, application_closing_at: 5.days.from_now)
      expect(event).to_not be_application_possible

      visit group_event_path(event.groups.first, event)

      expect(page).to_not have_css('a.btn', text: 'Anmelden', exact_text: true)
    end

    it 'with application window completely in the past is not allowed' do
      event = Fabricate(:event, application_opening_at: 5.days.ago, application_closing_at: 2.days.ago)
      expect(event).to_not be_application_possible

      visit group_event_path(event.groups.first, event)

      expect(page).to_not have_css('a.btn', text: 'Anmelden', exact_text: true)
    end
  end

  describe 'for a Course' do
    it 'in state application_open (without dates) is allowed' do
      course = Fabricate(:course, state: 'application_open')
      expect(course.application_opening_at).to be_nil
      expect(course.application_closing_at).to be_nil
      expect(course).to be_application_possible

      visit group_event_path(course.groups.first, course)

      expect(page).to have_css('a.btn', text: 'Anmelden', exact_text: true)
    end

    it 'in state application_open in the past is allowed (for now)' do
      course = Fabricate(:course, state: 'application_open', application_opening_at: 5.days.ago)
      expect(course).to be_application_possible

      visit group_event_path(course.groups.first, course)

      expect(page).to have_css('a.btn', text: 'Anmelden', exact_text: true)
    end

    it 'in state application_open in the future is not allowed' do
      course = Fabricate(:course, state: 'application_open', application_opening_at: 5.days.from_now)
      expect(course).to_not be_application_possible

      visit group_event_path(course.groups.first, course)

      expect(page).to_not have_css('a.btn', text: 'Anmelden', exact_text: true)
    end

    it 'in state application_closed it not allowed' do
      course = Fabricate(:course, state: 'application_closed')
      expect(course).to_not be_application_possible

      visit group_event_path(course.groups.first, course)

      expect(page).to_not have_css('a.btn', text: 'Anmelden', exact_text: true)
    end
  end
end
