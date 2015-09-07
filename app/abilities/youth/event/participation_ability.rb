# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      permission(:any).may(:cancel, :absent, :assign, :attend).for_participations_full_events
      permission(:group_full).may(:cancel, :reject, :absent, :assign, :attend).in_same_group
      permission(:group_and_below_full).
        may(:cancel, :reject, :absent, :assign, :attend).
        in_same_group_or_below
      permission(:layer_full).may(:cancel, :reject, :absent, :assign, :attend).in_same_layer
      permission(:layer_and_below_full).may(:cancel, :reject, :absent, :assign, :attend).
        in_same_layer

      permission(:group_full).may(:create_tentative).person_in_same_group
      permission(:group_and_below_full).may(:create_tentative).person_in_same_group_or_below
      permission(:layer_full).may(:create_tentative).person_in_same_layer
      permission(:layer_and_below_full).may(:create_tentative).person_in_same_layer_or_visible_below
      general(:create_tentative).event_tentative_and_person_in_tentative_group
    end
  end

  def person_in_same_group
    person.nil? || permission_in_groups?(person.groups.collect(&:id))
  end

  def person_in_same_group_or_below
    person.nil? ||
    permission_in_groups?(person.groups.collect(&:local_hierarchy).flatten.collect(&:id).uniq)
  end

  def person_in_same_layer
    person.nil? || permission_in_layers?(person.groups.collect(&:layer_group_id))
  end

  def person_in_same_layer_or_visible_below
    person.nil? || person_in_same_layer || visible_below
  end

  def event_tentative_and_person_in_tentative_group
    return false unless event.tentative_application_possible?

    groups = tentative_group_ids
    permission_in_groups?(groups) || permission_in_layers?(groups)
  end

  private

  def event
    participation.event
  end

  def person
    participation.person
  end

  def visible_below
    permission_in_layers?(participation.person.above_groups_where_visible_from.collect(&:id))
  end

  def tentative_group_ids
    event.groups.flat_map { |g| g.self_and_descendants.pluck(:id) + g.hierarchy.pluck(:id) }
  end


end
