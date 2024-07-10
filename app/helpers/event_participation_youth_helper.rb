# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module EventParticipationYouthHelper
  def format_event_participation_state(entry)
    entry.state_translated
  end
end
