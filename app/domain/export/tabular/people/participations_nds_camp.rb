# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class Export::Tabular::People::ParticipationsNdsCamp < Export::Tabular::Base

  self.model_class = ::Event::Participation
  self.row_class = ::Export::Tabular::People::ParticipationNdsRow

  def build_attribute_labels # rubocop:disable Metrics/MethodLength
    {
      j_s_number: 'PERSONENNUMMER',
      last_name: 'NAME',
      first_name: 'VORNAME',
      birthday: 'GEBURTSDATUM',
      gender: 'GESCHLECHT',
      ahv_number: 'AHV_NR',
      peid: 'PEID',
      nationality_j_s: 'NATIONALITAET',
      first_language: 'MUTTERSPRACHE',
      address: 'STRASSE',
      house_number: 'HAUSNUMMER',
      zip_code: 'PLZ',
      town: 'ORT',
      country: 'LAND',
    }
  end

end
