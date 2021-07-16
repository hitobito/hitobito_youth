# frozen_string_literal: true

#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ListsController
  extend ActiveSupport::Concern
  include Events::CourseListing

  included do
    class_attribute :bsv_course_states
    self.bsv_course_states = [:closed]
  end

  def bsv_export
    authorize!(:export_list, Event::Course)

    redirecting = flash_on_errors_and_redirect

    render_bsv_export(courses_for_bsv_export) unless redirecting
  end

  private

  def render_bsv_export(courses_for_bsv_export)
    send_data(Export::Tabular::Events::BsvList.csv(courses_for_bsv_export),
              type: :csv, filename: 'bsv_export.csv')
  end

  def flash_on_errors_and_redirect
    if !dates_from_to
      flash_and_redirect(:bsv_export_date_invalid)
    elsif [@date_from, @date_to].all?(&:blank?)
      flash_and_redirect(:bsv_export_params_missing)
    elsif date_to_newer_than_date_from?
      flash_and_redirect(:bsv_export_date_from_newer_than_date_to)
    end

    flash[:alert].present?
  end

  def flash_and_redirect(key)
    flash[:alert] = translate("courses.#{key}")
    redirect_to list_courses_path
  end

  def date_to_newer_than_date_from?
    (@date_from && @date_to) && (@date_from > @date_to)
  end

  def courses_for_bsv_export
    courses = course_filters
                  .to_scope
                  .includes(participations: [:roles, person: :location])
                  .order('event_dates.start_at')
  end

  def limited_courses_scope(courses)
    Events::Filter::Groups.new(
      current_person, params,
      { kind_used: kind_used?, list_all_courses: can?(:list_all, Event::Course) },
      courses
    ).to_scope
  end

  def dates_from_to
    date_from = params.dig(:filter, :bsv_since)
    date_to = params.dig(:filter, :bsv_until)
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
