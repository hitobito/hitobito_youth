# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::People
  class ParticipationNdsRow < Export::Tabular::People::PersonRow
    NDS_LANGUAGES = %w[DE FR IT].freeze

    attr_reader :participation

    def initialize(participation, format = nil)
      @participation = participation
      super(participation.person, format)
    end

    def j_s_number
      entry.j_s_number.to_s.try(:gsub, /\D/, '')
    end

    def gender
      entry.gender # prevent human_attribute
    end

    def birthday
      # date format defined by nds
      entry.birthday && entry.birthday.strftime('%d.%m.%Y')
    end

    def canton
      entry.canton.to_s.upcase
    end

    def country
      {
        'CH' => 'CH',
        'DE' => 'DE',
        'FL' => 'FL',
        'FR' => 'FR',
        'IT' => 'IT',
        'AT' => 'AT'
      }.fetch(entry.country, 'CH')
    end

    def nationality_j_s
      entry.nationality_j_s.presence || 'CH'
    end

    def phone_private
      phone_number('Privat')
    end

    def phone_work
      phone_number('Arbeit')
    end

    def phone_official
      nil
    end

    def email_official
      nil
    end

    def email_work
      additional_email('Arbeit')
    end

    def first_language
      language = entry.language.presence&.to_s&.upcase
      NDS_LANGUAGES.include?(language) ? language : 'Andere'
    end

    def second_language
      nil
    end

    def address
      split_address[1]
    end

    def house_number
      split_address[2]
    end

    def peid
      nil
    end

    def fetch(attr)
      super(attr).presence
    end

    private

    def phone_number(label)
      entry.phone_numbers.find_by(label: label).try(:number)
    end

    def additional_email(label)
      entry.additional_emails.find_by(label: label).try(:email)
    end

    def split_address
      entry.address&.match(Address::FullTextSearch::ADDRESS_WITH_NUMBER_REGEX)&.to_a ||
        [entry.address]
    end
  end
end
