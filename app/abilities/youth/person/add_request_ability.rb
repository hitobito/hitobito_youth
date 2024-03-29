# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Person::AddRequestAbility
  extend ActiveSupport::Concern

  included do
    on(Person::AddRequest) do
      for_self_or_manageds do
        # Skip add requests for managers adding their manageds somewhere
        permission(:any).may(:approve).herself
        permission(:any).may(:reject).herself_or_her_own
        permission(:any).may(:add_without_request).herself
      end
    end
  end
end
