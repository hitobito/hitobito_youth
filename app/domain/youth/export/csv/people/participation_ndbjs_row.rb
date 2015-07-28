# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Export::Csv::People
  class ParticipationNdbjsRow < Export::Csv::People::PersonRow

    attr_reader :participation

    def initialize(participation)
      @participation = participation
      super(participation.person)
    end

    def gender
      { 'm' => 1, 'f' => 2 }[entry.gender]
    end

    def ahv_number
      '?'
    end

    def canton
      '?'
    end

    def country
      if entry.swiss?
        'CH'
      end
    end

    def phone_private
      phone_number('Privat')
    end

    def phone_work
      phone_number('Arbeit')
    end

    def phone_mobile
      phone_number('Mobil')
    end

    def phone_fax
      phone_number('Fax')
    end

    def nationality
      '?'
    end

    def first_language
      lang = entry.correspondence_language
      lang.first.capitalize if lang.present?
    end

    def second_language
      nil
    end

    def profession
      3
    end

    def organisation
      nil
    end

    def association
      nil
    end

    def activity
      1
    end

    def attachments
      1
    end

    private

    def phone_number(label)
      entry.phone_numbers.find_by(label: label).try(:number)
    end

  end
end
