# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PersonReadables

  def accessible_conditions
    super.tap do |condition|
      condition.or(*manager_condition)
    end
  end

  def manager_condition
    ["people.id IN (#{PeopleManager.where(manager_id: user.id).select(:managed_id).to_sql})"]
  end

end
