# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PersonAbility
  extend ActiveSupport::Concern

  included do
    on(Person) do
      # Managers have almost all base permissions on the managed person
      for_self_or_manageds do
        permission(:any).
          may(:show, :show_details, :show_full, :history, :update, :update_email, :primary_group,
              :log, :totp_reset).
          herself

        class_side(:create_households).if_any_writing_permission_or_any_manageds
      end

      # People with update permission on a managed person also have the permission to update the
      # managers of that managed person
      permission(:group_full).may(:change_managers).
        non_restricted_in_same_group_except_self
      permission(:group_and_below_full).may(:change_managers).
        non_restricted_in_same_group_or_below_except_self
      permission(:layer_full).may(:change_managers).
        non_restricted_in_same_layer_except_self
      permission(:layer_and_below_full).may(:change_managers).
        non_restricted_in_same_layer_or_visible_below_except_self

      class_side(:lookup_manageds).if_any_writing_permissions
      permission(:any).may(:update_personal_readonly_attrs).not_self_or_managed
    end
  end

  def not_self_or_managed
    ((!not_self && !not_manager)).tap { |val| puts val }
  end

  def not_manager
    user.manageds.exclude?(person)
  end

  def if_any_writing_permission_or_any_manageds
    if_any_writing_permissions || user_context.user.manageds.any?
  end

  def non_restricted_in_same_group_except_self
    non_restricted_in_same_group && !herself
  end

  def non_restricted_in_same_group_or_below_except_self
    non_restricted_in_same_group_or_below && !herself
  end

  def non_restricted_in_same_layer_except_self
    non_restricted_in_same_layer && !herself
  end

  def non_restricted_in_same_layer_or_visible_below_except_self
    non_restricted_in_same_layer_or_visible_below && !herself
  end

end
