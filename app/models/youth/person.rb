# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Person
  extend ActiveSupport::Concern

  NATIONALITIES_J_S = %w[CH FL ANDERE].freeze

  included do
    Person::SEARCHABLE_ATTRS << :j_s_number

    validates :nationality_j_s, inclusion: {in: NATIONALITIES_J_S, allow_blank: true}
  end

  def valid_email?(email = self.email)
    if FeatureGate.enabled?("people.people_managers")
      super || Person.mailing_emails_for(self).any? { |mail| super(mail) }
    else
      super
    end
  end

  def last_known_ahv_number(participation_ids = event_participation_ids)
    Event::Answer.joins(:question, :participation)
      .where(participation: participation_ids)
      .where(event_questions: {type: Event::Question::AhvNumber.sti_name})
      .where.not(answer: [nil, ""])
      .order(Event::Participation.arel_table[:updated_at].desc)
      .last&.answer.presence
  end
end
