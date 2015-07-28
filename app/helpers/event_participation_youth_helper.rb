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
    (entry.assigned? || entry.applied?) && can?(:reject, entry)
  end

end
