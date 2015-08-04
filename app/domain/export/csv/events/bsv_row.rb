# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Csv::Events
  class BsvRow < Export::Csv::Row

    def vereinbarungs_id_fiver
      entry.kind.vereinbarungs_id_fiver
    end

    def kurs_id_fiver
      # TODO truncate ? max. 100 chars
      entry.kind.kurs_id_fiver
    end

    def oldest_event_date
      date = entry.dates.order(:start_at).try(:first)
      date && date.start_at.strftime('%d.%m.%Y')
    end

  end
end
