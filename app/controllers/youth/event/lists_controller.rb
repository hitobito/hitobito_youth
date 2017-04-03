# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ListsController
  extend ActiveSupport::Concern

  included do
    class_attribute :bsv_course_states
    self.bsv_course_states = [:closed]
  end

  def bsv_export
    authorize!(:export_list, Event::Course)
    set_group_vars

    if !dates_from_to
      set_flash_and_redirect(:bsv_export_date_invalid)
    elsif [@date_from, @date_to].all?(&:blank?)
      set_flash_and_redirect(:bsv_export_params_missing)
    elsif date_to_newer_than_date_from?
      set_flash_and_redirect(:bsv_export_date_from_newer_than_date_to)
    else
      send_data(Export::Tabular::Events::BsvList.csv(courses_for_bsv_export),
                type: :csv, filename: 'bsv_export.csv')
    end
  end

  private

  def set_flash_and_redirect(key)
    flash[:alert] = translate("courses.#{key}")
    redirect_to list_courses_path
  end

  def date_to_newer_than_date_from?
    (@date_from && @date_to) && (@date_from > @date_to)
  end

  def courses_for_bsv_export
    courses = Event::Course.
      joins(:dates).
      includes(participations: [:roles, person: :location])

    courses = limited_courses_scope(courses)
    courses = courses.where(state: bsv_course_states)
    courses = courses.where('event_dates.start_at = ' \
                            '(SELECT start_at FROM event_dates' \
                            ' WHERE event_dates.event_id = events.id' \
                            ' ORDER BY start_at DESC LIMIT 1)')

    courses = date_range_condition(courses, @date_from, '>=')
    courses = date_range_condition(courses, @date_to, '<=')

    if model_params.fetch(:event_kinds, []).reject(&:blank?).present?
      courses = courses.where(kind: model_params[:event_kinds])
    end

    courses.order('event_dates.start_at')
  end

  def date_range_condition(courses, date, operator)
    return courses unless date

    courses.where('(event_dates.finish_at IS NULL' \
                  " AND event_dates.start_at #{operator} ?)" \
                  " OR (event_dates.finish_at #{operator} ?)",
                  date, date)
  end

  def dates_from_to
    date_from = model_params[:date_from]
    date_to = model_params[:date_to]
    begin
      @date_from = Date.parse(date_from) if date_from.present?
      @date_to = Date.parse(date_to) if date_to.present?
    rescue ArgumentError
      return false
    end
    true
  end

  def model_params
    @model_params ||= params.fetch(:bsv_export, {})
  end

end
