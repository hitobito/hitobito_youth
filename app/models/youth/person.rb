# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Person
  extend ActiveSupport::Concern

  require_dependency 'social_security_number'
  include ::SocialSecurityNumber

  NATIONALITIES_J_S = %w(CH FL ANDERE).freeze

  included do
    has_many :people_managers, foreign_key: :managed_id,
                               dependent: :destroy
    has_many :people_manageds, class_name: 'PeopleManager',
                               foreign_key: :manager_id,
                               dependent: :destroy

    has_many :managers, through: :people_managers
    has_many :manageds, through: :people_manageds

    validates :nationality_j_s, inclusion: { in: NATIONALITIES_J_S, allow_blank: true }

    validate :assert_either_only_managers_or_manageds
    validate :validate_ahv_number
  end


  AHV_NUMBER_REGEX = /\A\d{3}\.\d{4}\.\d{4}\.\d{2}\z/

  def validate_ahv_number
    # Allow changing the password, even if there is an invalid AHV number in the database
    return if will_save_change_to_encrypted_password? && !will_save_change_to_ahv_number?
    return if ahv_number.blank?

    if ahv_number !~ AHV_NUMBER_REGEX
      errors.add(:ahv_number, :must_be_social_security_number_with_correct_format)
      return
    end
    unless checksum_validate(ahv_number).valid?
      errors.add(:ahv_number, :must_be_social_security_number_with_correct_checksum)
    end
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
    return [self] unless FeatureGate.enabled?('people.people_managers')

    [self, manageds].flatten
  end

  def checksum_validate(ahv_number)
    SocialSecurityNumber::Validator.new(number: ahv_number.to_s, country_code: 'ch')
  end

  def valid_email?(email = self.email)
    if FeatureGate.enabled?('people.people_managers')
      super(email) || Person.mailing_emails_for(self).any? { |mail| super(mail) }
    else
      super(email)
    end
  end
end
