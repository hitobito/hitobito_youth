#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :to_s, :state
  end

  def to_s_with_state(*)
    s = to_s_without_state(*)
    s << " (#{state_label})" if event.revoked_participation_states.include?(model.state)
    s
  end
end
