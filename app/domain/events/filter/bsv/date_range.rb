# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Events::Filter::Bsv
  class DateRange < Events::Filter::DateRange
    class << self
      def key
        "bsv_date_range"
      end
    end

    def apply(scope)
      return scope unless since_date && until_date

      courses = scope.joins(:dates).where(first_event_date_start)
      courses = date_range_condition(courses, since_date, ">=")
      date_range_condition(courses, until_date, "<=")
    end

    private

    def first_event_date_start
      <<-SQL.lines.map(&:strip).join(" ")
        event_dates.start_at = (
          SELECT start_at
          FROM event_dates
          WHERE event_dates.event_id = events.id
          ORDER BY start_at DESC
          LIMIT 1
        )
      SQL
    end

    def date_range_condition(courses, date, operator)
      courses.where("(event_dates.finish_at IS NULL" \
                  " AND event_dates.start_at #{operator} ?)" \
                  " OR (event_dates.finish_at #{operator} ?)",
        date, date)
    end
  end
end
