#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      for_self_or_manageds do
        # abilities which managers inherit from their managed children
        class_side(:list_available).if_any_role
        permission(:any).may(:show).in_same_layer_or_globally_visible_or_participating_or_public
      end
    end

    on(Event::Course) do
      for_self_or_manageds do
        # abilities which managers inherit from their managed children
        class_side(:list_available).if_any_role
        permission(:any).may(:show).in_same_layer_or_globally_visible_or_participating_or_public
      end

      permission(:any)
        .may(:index_revoked_participations, :list_tentatives)
        .for_participations_full_events
      permission(:group_full)
        .may(:index_revoked_participations, :list_tentatives)
        .in_same_group
      permission(:group_and_below_full)
        .may(:index_revoked_participations, :list_tentatives)
        .in_same_group_or_below
      permission(:layer_full)
        .may(:index_revoked_participations, :list_tentatives)
        .in_same_layer
      permission(:layer_and_below_full)
        .may(:index_revoked_participations, :list_tentatives)
        .in_same_layer_or_below

      general(:list_tentatives).if_tentative_applications?
    end
  end

  def if_tentative_applications?
    subject.tentative_applications?
  end

  def in_same_layer_or_globally_visible_or_participating_or_public
    in_same_layer_or_globally_visible_or_participating || event.external_applications
  end
end
