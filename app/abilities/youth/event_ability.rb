# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Course) do
      permission(:any).
        may(:index_revoked_participations, :list_tentatives).
        for_participations_full_events
      permission(:group_full).
        may(:index_revoked_participations, :list_tentatives).
        in_same_group
      permission(:layer_full).
        may(:index_revoked_participations, :list_tentatives).
        in_same_layer
      permission(:layer_and_below_full).
        may(:index_revoked_participations, :list_tentatives).
        in_same_layer_or_below

      general(:list_tentatives).if_tentative_applications?

    end

    on(Event::Course) do
      class_side(:bsv_export).layer_full_on_root?
    end

  end

  def layer_full_on_root?
    #role_types = group.root.role_types.select { |r| r.permissions.include?(:layer_and_below_full) }
    #user.roles.any? { |r| role_types.any? { |role_type| r.is_a?(role_type) } }
    true
  end

  def if_tentative_applications?
    subject.tentative_applications?
  end

end
