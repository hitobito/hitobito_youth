# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class Group::EducationsController < ApplicationController

  helper_method :group
  decorates :group, :people

  def index
    authorize!(:education, group)
    @people = education_entries.page(params[:page])
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def education_entries
    filter_entries.
      includes(qualifications: { qualification_kind: :translations },
               event_participations: { event: [:groups, :dates] })
  end

  def filter_entries
    filter = list_filter
    entries = filter.filter_entries.order_by_name
    @multiple_groups = filter.multiple_groups
    @all_count = filter.all_count if html_request?
    entries
  end

  def list_filter
    if params[:filter] == 'qualification'
      Person::QualificationFilter.new(group, current_user, params)
    else
      Person::RoleFilter.new(group, current_user, params)
    end
  end

end
