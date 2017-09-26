# encoding: utf-8

#  Copyright (c) 2014-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::FilterNavigation::People
  extend ActiveSupport::Concern

  included do
    alias_method_chain :path, :education
    alias_method_chain :new_group_people_filter_path, :education
    alias_method_chain :delete_group_people_filter_path, :education
  end

  private

  def path_with_education(options = {})
    if education?
      template.educations_path(group, options)
    else
      path_without_education(options)
    end
  end

  def new_group_people_filter_path_with_education
    template.new_group_people_filter_path(
        group.id,
        education: education?,
        range: filter.range,
        filters: filter.chain.to_params
    )
  end

  def delete_group_people_filter_path_with_education(filter)
    template.group_people_filter_path(group, filter, education: education?)
  end

  def qualification_group_people_filter_path_with_education
    template.qualification_group_people_filters_path(
      group.id,
      qualification_kind_id: qualification_kind_ids,
      kind: deep,
      validity: validity,
      education: education?,
      match: match,
      start_at_year_from: @params[:start_at_year_from],
      start_at_year_until: @params[:start_at_year_until],
      finish_at_year_from: @params[:finish_at_year_from],
      finish_at_year_until: @params[:finish_at_year_until])
  end

  def education?
    template.controller_name == 'educations'
  end

end
