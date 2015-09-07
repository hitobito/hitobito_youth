# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:group_full).may(:education).in_same_group
      permission(:group_and_below_full).may(:education).in_same_group_or_below
      permission(:layer_full).may(:education).in_same_layer
      permission(:layer_and_below_full).may(:education).in_same_layer_or_below

      general(:education).if_layer_group
    end
  end

  def if_layer_group
    group.layer?
  end
end
