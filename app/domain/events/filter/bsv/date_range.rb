# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Events::Filter::Bsv
  class DateRange
    def initialize(_user, params, _options, scope)
      @params = params
      @scope = scope
    end

    def to_scope
      return @scope unless start_date.present? && end_date.present?

      courses = @scope.joins(:dates).where(first_event_date_start)
      courses = date_range_condition(courses, start_date, ">=")
      date_range_condition(courses, end_date, "<=")
    end

    private

    def start_date
      date_or_default(@params.dig(:filter, :bsv_since), nil)
    end

    def end_date
      date_or_default(@params.dig(:filter, :bsv_until), nil)
    end

    def date_or_default(date, default)
      Date.parse(date)
    rescue
      default
    end

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
