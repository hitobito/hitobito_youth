#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      permission(:any).may(:cancel, :absent, :assign, :attend).for_participations_full_events
      permission(:group_full).may(:cancel, :reject, :absent, :assign, :attend).in_same_group
      permission(:group_and_below_full)
        .may(:cancel, :reject, :absent, :assign, :attend)
        .in_same_group_or_below
      permission(:layer_full).may(:cancel, :reject, :absent, :assign, :attend).in_same_layer
      permission(:layer_and_below_full).may(:cancel, :reject, :absent, :assign, :attend)
        .in_same_layer

      permission(:layer_full).may(:create_tentative).person_in_same_layer
      permission(:layer_and_below_full).may(:create_tentative).person_in_same_layer_or_visible_below
      general(:create_tentative).event_tentative_and_person_in_tentative_group
      general(:cancel, :reject, :absent, :assign, :attend).if_application
    end
  end

  def person_in_same_layer
    person.nil? || permission_in_layers?(person.layer_group_ids)
  end

  def person_in_same_layer_or_visible_below
    person_in_same_layer || visible_below
  end

  def event_tentative_and_person_in_tentative_group
    return false unless event.tentative_application_possible?

    groups = tentative_group_ids
    permission_in_layers?(groups)
  end

  def if_application
    event.supports_applications && participation.application_id?
  end

  private

  def event
    participation.event
  end

  def visible_below
    permission_in_layers?(person.above_groups_where_visible_from.collect(&:id))
  end

  def tentative_group_ids
    event.groups.flat_map { |g| g.self_and_descendants.pluck(:id) + g.hierarchy.pluck(:id) }
  end
end
