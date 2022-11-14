# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class Export::Tabular::People::ParticipationsNdsCourse < Export::Tabular::Base

  self.model_class = ::Event::Participation
  self.row_class = ::Export::Tabular::People::ParticipationNdsRow

  # rubocop:disable Metrics/MethodLength
  def build_attribute_labels
    { j_s_number: 'PERSONENNUMMER',
      last_name: 'NAME',
      first_name: 'VORNAME',
      birthday: 'GEBURTSDATUM',
      gender: 'GESCHLECHT',
      ahv_number: 'AHV_NR',
      peid: 'PEID',
      nationality_j_s: 'NATIONALITAET',
      first_language: 'MUTTERSPRACHE',
      second_language: 'ZWEITSPRACHE',
      address: 'STRASSE',
      house_number: 'HAUSNUMMER',
      zip_code: 'PLZ',
      town: 'ORT',
      country: 'LAND',
      phone_private: 'TELEFON (PRIVAT)',
      phone_official: 'TELEFON (AMTLICH)',
      phone_work: 'TELEFON (GESCHAEFT)',
      email: 'EMAIL (PRIVAT)',
      email_official: 'EMAIL (AMTLICH)',
      email_work: 'EMAIL (GESCHAEFT)'
    }
  end
  # rubocop:enable Metrics/MethodLength

end
