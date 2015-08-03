# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module EventParticipationYouthHelper

  def participates_in?(event)
    event.participations.
      where(person: current_user).
      where.not(state: 'tentative').exists?
  end

  def show_event_participation_cancel_button?
    (entry.assigned? || entry.applied?) && can?(:cancel, entry)
  end

  def show_event_participation_reject_button?
    entry.applied? && can?(:reject, entry)
  end

  def show_event_participation_absent_button?
    (entry.assigned? || entry.attended?) && can?(:absent, entry)
  end

  def show_event_participation_attended_button?
    (entry.absent? && entry.event.completed?) && can?(:attend, entry)
  end

  def show_event_participation_assigned_button?
    (entry.absent? && !entry.event.completed?) && can?(:assign, entry)
  end

  def format_event_participation_state(entry)
    I18n.t("activerecord.attributes.event/participation.states.#{entry.state}")
  end
end
