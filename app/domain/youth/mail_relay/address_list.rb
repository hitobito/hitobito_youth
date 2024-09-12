# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::MailRelay::AddressList
  extend ActiveSupport::Concern

  included do
    def people
      persisted_people, new_people = *@people.partition(&:persisted?)
      new_people_and_their_managers = new_people + new_people.flat_map(&:managers)
      return new_people_and_their_managers if persisted_people.blank?

      people_and_their_managers(persisted_people) + new_people_and_their_managers
    end
  end

  private

  def people_and_their_managers(people)
    Person.left_joins(:people_manageds).distinct
      .where(people_manageds: {managed_id: people})
      .or(Person.distinct.where(id: people))
  end
end
