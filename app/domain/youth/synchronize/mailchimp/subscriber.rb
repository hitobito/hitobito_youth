# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Synchronize::Mailchimp::Subscriber
  extend ActiveSupport::Concern

  prepended do
    def self.recipients(mailing_list)
      people = mailing_list.people.pluck(:id)
      Person.left_joins(:people_manageds).distinct
        .where(people_manageds: {managed_id: people})
        .or(Person.distinct.where(id: people))
    end
  end
end
