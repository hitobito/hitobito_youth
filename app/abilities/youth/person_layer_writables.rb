# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PersonLayerWritables
  def accessible_people
    if user.root?
      super
    else
      super.left_joins(:people_managers)
    end
  end

  def writable_conditions
    super.tap do |condition|
      condition.or(*manager_condition)
    end
  end

  def manager_condition
    ["people_managers.manager_id = ?", user.id]
  end
end
