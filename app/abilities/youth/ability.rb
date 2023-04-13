# frozen_string_literal: true

# Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
# hitobito_youth and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https ://github.com/hitobito/hitobito_youth.

# Adds to the core the option to specify ability conditions like this:
# on(Event) do
#   for_self_or_manageds do
#     permission(:foo).may(:bar).some_condition
#   end
# end
# The condition will then grant permission when either the logged in user or one
# of their manageds is granted permission. I.e. the logged in user inherits the
# permissions of his manageds.
# Technically, this is implemented by normally generating the "can :foo, :bar"
# statements from the stored ability configs, and then for each of the manageds
# generating additional "can :foo, :bar" statements (but only the ones which
# originate inside a for_self_or_manageds block in the ability DSL).
module Youth::Ability

  private

  def define_user_abilities(current_store, current_user_context)
    super

    user.manageds.each do |managed|
      managed_user_context = AbilityDsl::UserContext.new(managed)
      managed_store = current_store.only_manager_inheritable

      super(managed_store, managed_user_context)
    end
  end
end
