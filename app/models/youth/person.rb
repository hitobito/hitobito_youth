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

    has_many :people_managers, foreign_key: :managed_id,
      dependent: :destroy
    has_many :people_manageds, class_name: "PeopleManager",
      foreign_key: :manager_id,
      dependent: :destroy

    has_many :managers, through: :people_managers
    has_many :manageds, through: :people_manageds

    validates :nationality_j_s, inclusion: {in: NATIONALITIES_J_S, allow_blank: true}

    validate :assert_either_only_managers_or_manageds
  end

  def assert_either_only_managers_or_manageds # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
    existent_managers = people_managers.reject { |pm| pm.marked_for_destruction? }
    existent_manageds = people_manageds.reject { |pm| pm.marked_for_destruction? }

    if existent_managers.any? && existent_manageds.any?
      errors.add(:base, :cannot_have_managers_and_manageds, name: full_name)
    elsif PeopleManager.exists?(managed: existent_managers.map(&:manager_id))
      errors.add(:base, :manager_already_managed)
    elsif PeopleManager.exists?(manager: existent_manageds.map(&:managed_id))
      errors.add(:base, :managed_already_manager)
    end
  end

  def and_manageds
    return [self] unless FeatureGate.enabled?("people.people_managers")

    [self, manageds].flatten
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
