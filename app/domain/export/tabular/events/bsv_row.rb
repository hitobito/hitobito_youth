# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::Events
  class BsvRow < Export::Tabular::Row

    delegate :training_days, :vereinbarungs_id_fiver, :participant_count,
             :leader_count, :canton_count, :language_count,
             to: :info

    def kurs_id_fiver
      info.kurs_id_fiver.to_s.truncate(100) if info.kurs_id_fiver
    end

    def location
      info.location.to_s.truncate(200) if info.location
    end

    def first_event_date
      info.first_event_date.strftime('%d.%m.%Y')
    end

    private

    def info
      @info ||= Bsv::Info.new(entry)
    end

  end
end
