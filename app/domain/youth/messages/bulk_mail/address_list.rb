# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Messages::BulkMail::AddressList

  def preferred_addresses(person)
    # TODO performance? .includes is not possible i believe since its an Array

    super(person) + person.managers.flat_map { |manager| super(manager) }
  end

  def default_addresses(person)
    super(person) + person.managers.flat_map { |manager| super(manager) }
  end

  def additional_emails_scope
    AdditionalEmail.where(contactable_type: Person.sti_name,
                          contactable_id: (people + people.flat_map(&:managers)).map(&:id))
  end
end
