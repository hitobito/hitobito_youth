# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Csv::Events
  class BsvList < Export::Csv::Base

    self.model_class = ::Event::Course
    self.row_class = Export::Csv::Events::BsvRow

    class << self
      def export(*args)
        super.gsub(/\n/,"\r\n") # use CRLF instead of LF as specified by BSV
      end
    end

    def attribute_labels
      { vereinbarungs_id_fiver: 'Vereinbarung-ID-FiVer',
        kurs_id_fiver: 'Kurs-ID-FiVer',
        number: 'Kursnummer',
        first_event_date: 'Datum',
        location: 'Kursort',
        training_days: 'Ausbildungstage',
        participant_count: 'Teilnehmende (17-30)',
        leader_count: 'Kursleitende',
        canton_count: 'Wohnkantone der TN',
        language_count: 'Sprachen' }
    end

  end
end
