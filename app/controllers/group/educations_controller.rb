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
    @person_filter = Person::Filter::List.new(group, current_user, list_filter_args)
    entries = @person_filter.entries.reorder(:birthday)
    entries
  end

  def list_filter_args
    if params[:filter_id]
      filter = PeopleFilter.for_group(group).find(params[:filter_id])
      { name: filter.name, range: filter.range, filters: filter.filter_chain.to_hash }
    else
      params
    end
  end

end
