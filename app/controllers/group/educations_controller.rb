#  Copyright (c) 2012-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class Group::EducationsController < ApplicationController
  include Sortable

  helper_method :group
  decorates :group, :people

  class << self
    def sort_mappings_with_indifferent_access
      @sort_mappings_with_indifferent_access ||=
        {
          name: Person.order_by_name_statement,
          qualification: {joins: qualification_order_join,
                          order: ["sort_qualifications.finish_at",
                            Person.order_by_name_statement]},
          birthday: ["people.birthday", Person.order_by_name_statement]
        }.with_indifferent_access
    end

    private

    def qualification_order_join
      "LEFT JOIN (#{earliest_qualification_kind_finish.to_sql}) sort_qualifications " \
        "ON sort_qualifications.person_id = people.id"
    end

    # Of all qualification kinds shown for a person, the one expiring first
    # determines the order.
    def earliest_qualification_kind_finish
      Qualification
        .select("person_id", "MIN(finish_at) AS finish_at")
        .from(latest_finish_per_qualification_kind, :qualification_kind_finishes)
        .group("person_id")
    end

    def latest_finish_per_qualification_kind
      Qualification
        .select("qualifications.person_id",
          "MAX(COALESCE(qualifications.finish_at, 'infinity')) AS finish_at")
        .joins(:qualification_kind)
        # same condition as Qualification#reactivateable?
        .where("qualifications.finish_at IS NULL OR qualifications.finish_at + " \
               "COALESCE(qualification_kinds.reactivateable, 0) * INTERVAL '1 year' " \
               ">= CURRENT_DATE")
        .group("qualifications.person_id", "qualifications.qualification_kind_id")
    end
  end

  def index
    authorize!(:education, group)
    @people = list_entries.page(params[:page])
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def model_class = Person

  def list_entries
    person_filter.entries.includes(
      qualifications: {qualification_kind: :translations},
      event_participations: {event: [:groups, :dates]}
    )
  end

  def person_filter
    @person_filter ||= Person::Filter::List.new(group, current_user, list_filter_args)
  end

  def list_filter_args
    if params[:filter_id]
      filter = PeopleFilter.for_group(group).find(params[:filter_id])
      {name: filter.name, range: filter.range, filters: filter.filter_chain.to_hash}
    else
      params
    end
  end
end
