# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::People::CleanupFinder
  def run
    Person.where(id: super.map(&:id))
      .left_joins(:people_manageds)
      .where(no_people_manageds_exist)
      .distinct
  end

  private

  def no_people_manageds_exist
    people_manageds.arel.exists.not
  end

  def people_manageds
    PeopleManager.where("people_managers.manager_id = people.id")
  end
end
