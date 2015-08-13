# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ListsController
  extend ActiveSupport::Concern

  included do
    attr_accessor :date_from, :date_to
    before_filter :dates_from_to, only: [:bsv_export]
  end

  def bsv_export
    authorize!(:bsv_export, Event::Course) # replace with ability
    if date_from || date_to
      if (date_from && date_to) && (date_from > date_to)
        flash[:alert] = translate('courses.bsv_export_date_from_never_than_date_to') 
        redirect_to list_courses_path
      else
        send_data(Export::Csv::Events::BsvList.export(courses_for_bsv_export),
                type: 'text/csv', filename: 'bsv_export.csv')
      end
    else
      flash[:alert] = translate('courses.bsv_export_params_missing') 
      redirect_to list_courses_path
    end
  end

  private

  def courses_for_bsv_export
    courses = Event::Course.joins(:dates)
    courses = courses.where(state: 'closed')
    courses = courses.where('event_dates.start_at = ' \
                            '(SELECT start_at FROM event_dates' \
                            ' WHERE event_dates.event_id = events.id' \
                            ' ORDER BY start_at DESC LIMIT 1)')

    courses = date_range_condition(courses, date_from, '>=')
    courses = date_range_condition(courses, date_to, '<=')

    if params[:event_kinds].present?
      courses = courses.where(kind: params[:event_kinds])
    end
    courses
  end

  def date_range_condition(courses, date, operator)
    if date
      courses = courses.where("(event_dates.finish_at IS NULL AND event_dates.start_at #{operator} ?) OR (event_dates.finish_at #{operator} ?)", date, date)
    end
    courses
  end

  def dates_from_to
    date_from, date_to = params[:date_from], params[:date_to]
    @date_from = Date.parse(date_from) if date_from.present?
    @date_to = Date.parse(date_to) if date_to.present?
  end

end
