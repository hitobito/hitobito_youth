# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth
#  and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::People::Merger
  extend ActiveSupport::Concern

  def merge_associations
    super
    merge_people_managers
    merge_people_manageds
  end

  def merge_people_managers
    return unless @target.people_managers.any?

    @source.people_managers.each do |pm|
      next if PeopleManager.exists?(managed: @target, manager: pm.manager)

      dup = pm.dup
      dup.managed = @target
      dup.save!
    end
  end

  def merge_people_manageds
    return unless @target.people_manageds.any?

    @source.people_manageds.each do |pm|
      next if PeopleManager.exists?(manager: @target, managed: pm.managed)

      dup = pm.dup
      dup.manager = @target
      dup.save!
    end
  end
end
