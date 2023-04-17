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
    def self.default_and_additional_addresses(mailing_list)
      people = mailing_list.people
      manager_ids = PeopleManager.where(managed_id: people.pluck(:id)).pluck(:manager_id)
      people = Person.where(id: people.pluck(:id) + manager_ids)

      additional_emails = AdditionalEmail.where(contactable_type: Person.sti_name,
                                                contactable_id: people.collect(&:id),
                                                mailings: true).to_a
      people.flat_map do |person|
        additional_email_subscribers = additional_emails.select do |additional_email|
          additional_email.contactable_id == person.id
        end.map do |additional_email|
          self.new(person, additional_email.email)
        end
        [self.new(person, person.email)] + additional_email_subscribers
      end
    end

    def self.default_addresses(mailing_list)
      people = mailing_list.people
      manager_ids = PeopleManager.where(managed_id: people.pluck(:id)).pluck(:manager_id)
      people = Person.where(id: people.pluck(:id) + manager_ids)

      people.map do |person|
        self.new(person, person.email)
      end
    end
  end
end
