# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Csv::People
  class ParticipationNdbjsRow < Export::Csv::People::PersonRow

    attr_reader :participation

    def initialize(participation)
      @participation = participation
      super(participation.person)
    end

    def gender
      { 'm' => 1, 'f' => 2 }[entry.gender]
    end

    def birthday
      # date format defined by ndbjs
      entry.birthday && entry.birthday.strftime('%d.%m.%Y')
    end

    def canton
      entry.canton.to_s.upcase
    end

    def country
      { 'CH' => 'CH',
        'DE' => 'D',
        'FL' => 'FL',
        'FR' => 'F',
        'IT' => 'I',
        'AT' => 'A'
      }[entry.country]
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

    def first_language
      'D'
    end

    def second_language
      nil
    end

    def profession
      3 # andere
    end

    def organisation
      nil
    end

    def association
      nil
    end

    def activity
      1 # mit kindern / jugendlichen j+s
    end

    def attachments
      1 # keine
    end

    def class_group
      nil
    end

    private

    def phone_number(label)
      entry.phone_numbers.find_by(label: label).try(:number)
    end

  end
end
