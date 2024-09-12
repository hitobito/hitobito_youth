#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Person::AddRequest::Approver::Event
  extend ActiveSupport::Concern

  included do
    alias_method_chain :set_active, :state
  end

  private

  def set_active_with_state(participation)
    set_active_without_state(participation)
    if participation.states?
      state = "assigned"
      unless event.possible_participation_states.include?(state)
        state = event.default_participation_state(participation)
      end
      participation.state = state
    end
  end
end
