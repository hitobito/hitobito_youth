# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::People
  class ParticipationsSlrgRow < Export::Tabular::Row
    delegate :gender, :last_name, :first_name, :language, :email,
      :address, :zip_code, :town, to: :person

    def slrg_id
      ""
    end

    def slrg_status
      ""
    end

    def slrg_empty
      ""
    end

    def slrg_remarks
      ""
    end

    def gender
      if person.gender == "m"
        "Männlich / Masculin / Maschile"
      elsif person.gender == "w"
        "Weiblich / Féminin / Femminile"
      else
        ""
      end
    end

    def salutation
      ""
    end

    def phone_private
      ""
    end

    def phone_mobile
      ""
    end

    def birthday
      person.birthday&.iso8601
    end

    def country
      (person.country == "CH") ? "Schweiz" : person.country
    end

    private

    def person
      @person ||= entry.person
    end
  end
end
