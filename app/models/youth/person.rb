# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Person
  extend ActiveSupport::Concern

  require_dependency 'social_security_number'
  include ::SocialSecurityNumber

  NATIONALITIES_J_S = %w(CH FL DIV).freeze

  included do
    validates :nationality_j_s, inclusion: { in: NATIONALITIES_J_S, allow_blank: true }
    validate :validate_ahv_number
  end


  AHV_NUMBER_REGEX = /\A\d{3}\.\d{4}\.\d{4}\.\d{2}\z/

  def validate_ahv_number
    if ahv_number.nil?
    elsif !checksum_validate(ahv_number).valid? || ahv_number !~ AHV_NUMBER_REGEX
      errors.add(:ahv_number, :must_be_valid_social_security_number)
    end
  end

  def checksum_validate(ahv_number)
    SocialSecurityNumber::Validator.new(number: ahv_number.to_s, country_code: 'ch')
  end

end
