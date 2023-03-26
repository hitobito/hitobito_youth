# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::People
  class ParticipationsSlrgList < Export::Tabular::Base

    self.model_class = ::Event::Participation
    self.row_class = Export::Tabular::People::ParticipationsSlrgRow

    # rubocop:disable Metrics/MethodLength
    def attribute_labels
      {
        slrg_id: 'SLRG-Nr.',
        gender: 'Geschlecht',
        last_name: 'Name',
        first_name: 'Vorname',
        slrg_status: 'Status (neu / bestehend)',
        language: 'Sprache',
        salutation: 'Anrede',
        phone_private: 'Telefon Privat',
        phone_mobile: 'Telefon Mobile',
        email: 'E-Mail',
        birthday: 'Geburtsdatum',
        slrg_empty: '(leere Spalte L)',
        slrg_remarks: 'Bemerkung',
        address: 'Strasse',
        zip_code: 'PLZ',
        town: 'Ort',
        country: 'Land',
      }
    end
    # rubocop:enable Metrics/MethodLength

  end
end
