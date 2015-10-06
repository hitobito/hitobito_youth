# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module EventParticipationYouthHelper

  def show_event_participation_cancel_button?
    course_participation_state_transition_allowed?(:cancel, :assigned, :applied)
  end

  def show_event_participation_reject_button?
    course_participation_state_transition_allowed?(:reject, :applied)
  end

  def show_event_participation_absent_button?
    course_participation_state_transition_allowed?(:absent, :assigned, :attended)
  end

  def show_event_participation_attended_button?
    course_participation_state_transition_allowed?(:attend, :absent) && entry.event.closed?
  end

  def show_event_participation_assigned_button?
    course_participation_state_transition_allowed?(:assign, :absent) && !entry.event.closed?
  end

  def format_event_participation_state(entry)
    entry.state_translated
  end

  private

  def course_participation_state_transition_allowed?(to_state, *from_states)
    from_states.collect(&:to_s).include?(entry.state) && can?(to_state, entry)
  end
end
