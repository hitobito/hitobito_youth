#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::InvitationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Invitation) do
      for_self_or_manageds do
        # abilities which managers inherit from their managed children
        permission(:any).may(:decline).own_invitation
      end
    end
  end
end
