#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      # abilities which managers inherit from their managed children
      permission(:any).may(:show).her_own_or_manager_or_for_participations_read_events
      permission(:any).may(:show_details, :print)
        .her_own_or_manager_or_for_participations_full_events

      for_self_or_manageds do
        permission(:any).may(:create).her_own_if_application_possible
        permission(:any).may(:destroy).her_own_if_application_cancelable
        general(:create).at_least_one_group_not_deleted
      end

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

    alias_method_chain :participant_can_show_event?, :no_managed_regards
  end

  def her_own_or_manager_or_for_participations_read_events
    her_own_or_for_participations_read_events || manager
  end

  def her_own_or_manager_or_for_participations_full_events
    her_own_or_for_participations_full_events || manager
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

  def participant_can_show_event_with_no_managed_regards?
    participation.person &&
      (AbilityWithoutManagerAbilities.new(participation.person).can? :show, participation.event)
  end

  private

  def manager
    contains_any?([user.id], person.managers.pluck(:id))
  end

  def event
    participation.event
  end

  def person
    participation.person
  end

  def visible_below
    permission_in_layers?(person.above_groups_where_visible_from.collect(&:id))
  end

  def tentative_group_ids
    event.groups.flat_map { |g| g.self_and_descendants.pluck(:id) + g.hierarchy.pluck(:id) }
  end
end
