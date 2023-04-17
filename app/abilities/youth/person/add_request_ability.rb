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
      permission(:any).may(:approve).herself_or_managed
      permission(:any).may(:reject).herself_or_her_own_or_managed
      permission(:any).may(:add_without_request).herself_or_managed
    end
  end

  def herself_or_managed
    herself ||
      contains_any?([person.id], user.manageds.pluck(:id))
  end

  def herself_or_her_own_or_managed
    herself_or_managed ||
      her_own ||
      contains_any?([subject.requester_id], user.manageds.pluck(:id))
  end

end
