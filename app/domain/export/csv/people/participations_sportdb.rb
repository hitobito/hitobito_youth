# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

#
module Export::Csv::People
  class ParticipationsSportdb < Export::Csv::Base

    self.model_class = ::Event::Participation
    self.row_class = ::Export::Csv::People::ParticipationNdbjsRow

    def build_attribute_labels
      { j_s_number: 'NDBJS_PERS_NR',
        gender: 'GESCHLECHT',
        last_name: 'NAME',
        first_name: 'VORNAME',
        birthday: 'GEB_DATUM',
        address: 'STRASSE',
        zip_code: 'PLZ',
        town: 'ORT',
        country: 'LAND',
        nationality_j_s: 'NATIONALITAET',
        first_language: 'ERSTSPRACHE',
        class_group: 'KLASSE/GRUPPE'
      }
    end

  end
end
