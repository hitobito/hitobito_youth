# frozen_string_literal: true

#  Copyright (c) 2012-2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class Event::TentativesController < ApplicationController
  include RenderPeopleExports

  helper_method :group, :entry, :model_class, :entry
  helper_method :tentative_participants
  before_action :load_group_and_event

  decorates :event, :group

  def index
    authorize!(:list_tentatives, @event)

    respond_to do |format|
      format.html { @counts = count_tentative_participations(@event) }
      format.csv { render_tabular(:csv, tentative_participants) }
      format.xlsx { render_tabular(:xlsx, tentative_participants) }
    end
  end

  def new
    authorize!(:create_tentative, build)
  end

  def create
    authorize!(:create_tentative, build_for_person)

    if @participation.save
      flash[:notice] = t("event.tentatives.created", participant: @participation.person)
      redirect_to group_event_path(@group, @event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def query
    authorize!(:query, Person)
    people = []

    if params.key?(:q) && params[:q].size >= 3
      people = Person.accessible_by(PersonLayerWritables.new(current_user))
        .where(search_condition(*Person::QueryController.search_columns))
        .order_by_name
        .limit(10)
        .decorate
    end

    render json: people.collect(&:as_typeahead)
  end

  private

  def tentative_participants
    @entries ||= @event.participations.where(state: "tentative") # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def load_group_and_event
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:event_id]) # could be any event-kind (course, camp, ...)
  end

  def build
    @participation = @event.participations.new(state: "tentative")
  end

  def build_for_person
    participation = @event.participations.new(state: "tentative",
      participant_id: params[:event_participation][:participant_id],
      participant_type: Person.sti_name)

    role = participation.roles.build(type: @event.participant_types.first.sti_name)
    role.participation = participation

    @participation = participation
  end

  # Compose the search condition with a basic SQL OR query, copied from lists_controller
  # rubocop:todo Metrics/AbcSize
  def search_condition(*columns) # rubocop:todo Metrics/CyclomaticComplexity # rubocop:todo Metrics/AbcSize
    if columns.present? && params[:q].present?
      terms = params[:q].split(/\s+/).collect { |t| "%#{t}%" }
      clause = columns.collect do |f|
        col = f.to_s.include?(".") ? f : "people.#{f}"
        "#{col} LIKE ?"
      end.join(" OR ")
      clause = terms.collect { |_| "(#{clause})" }.join(" AND ")

      ["(#{clause})"] + terms.collect { |t| [t] * columns.size }.flatten
    end
  end
  # rubocop:enable Metrics/AbcSize

  def count_tentative_participations(event)
    event
      .participations
      .where(state: "tentative")
      # rubocop:todo Layout/LineLength
      .joins("LEFT OUTER JOIN #{Person.quoted_table_name} people " \
        "ON #{Event::Participation.quoted_table_name}.participant_type = '#{Person.sti_name}' " \
        "AND #{Event::Participation.quoted_table_name}.participant_id = #{Person.quoted_table_name}.id")
      # rubocop:enable Layout/LineLength
      .joins("LEFT OUTER JOIN #{Group.quoted_table_name} " \
        "ON #{Group.quoted_table_name}.id = #{Person.quoted_table_name}.primary_group_id")
      .joins("LEFT OUTER JOIN #{Group.quoted_table_name} layer_groups " \
        "ON #{Group.quoted_table_name}.layer_group_id = layer_groups.id")
      .group("layer_groups.id", "layer_groups.name")
      .order("layer_groups.lft")
      .count
  end

  def render_tabular(format, entries)
    send_data(Export::Tabular::People::ParticipationsAddress.export(format, entries), type: format)
  end
end
