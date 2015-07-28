# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

#
module Youth::Export::Csv::People
  class ParticipationsNdbjs < Export::Csv::Base

    self.model_class = ::Event::Participation
    self.row_class = Youth::Export::Csv::People::ParticipationNdbjsRow

    def build_attribute_labels
      # { j_s_number: 'NDS_PERSONEN_NR',
      # gender: 'GESCHLECHT',
      # last_name: 'NAME',
      # first_name: 'VORNAME',
      # birthday: 'GEBURTSDATUM',
      # ahv_number: 'AHV_NUMMER',
      # address: 'STREET',
      # zip_code: 'PLZ',
      # town: 'ORT',
      # canton: 'KANTON',
      # country: 'LAND',
      # phone_private: 'TELEFON_PRIVAT',
      # phone_work: 'TELEFON_GESCHAEFT',
      # phone_mobile: 'TELEFON_MOBIL',
      # phone_fax: 'FAX',
      # email: 'EMAIL',
      # nationality: 'NATIONALITAET',
      # first_language: 'ERSTSPRACHE',
      # second_language: 'ZWEITSPRACHE',
      # profession: 'BERUF',
      # organisation: 'VERPFLICHT_ORG',
      # association: 'VERPFLICHT_VERB',
      # activity: 'TAETIGKEIT',
      # attachments: 'BEILAGEN'
      # }
    end

  end
end
