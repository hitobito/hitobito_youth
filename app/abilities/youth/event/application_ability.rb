#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ApplicationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Application) do
      for_self_or_manageds do
        # abilities which managers inherit from their managed children
        permission(:any).may(:show_priorities, :show_approval).her_own
      end
    end
  end
end
