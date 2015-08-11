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

    def attributes
      [ :vereinbarungs_id_fiver,
        :kurs_id_fiver,
        :number,
        :oldest_event_date,
        :location,
        :training_days,
        :participant_count,
        :leader_count,
        :canton_count,
        :languages_count
      ]
    end

    def to_csv(generator)
      list.each do |entry|
        generator << values(entry)
      end
    end

  end
end
