# frozen_string_literal: true

# Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
# hitobito_youth and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https ://github.com/hitobito/hitobito_youth.

# Extends the ability DSL with the for_self_or_manageds syntax.
# All ability conditions in such a block are granted if either the current user
# or one of their manageds (children) individually is granted the ability.
# In other words, if the abilities defined in a for_self_or_manageds block are granted
# to my child, I automatically get the same abilities.
module Youth::AbilityDsl::Recorder
  def for_self_or_manageds
    return unless block_given?

    original_include_manageds = AbilityDsl::Recorder::Base.include_manageds
    AbilityDsl::Recorder::Base.include_manageds = true
    yield
    AbilityDsl::Recorder::Base.include_manageds = original_include_manageds
  end

  # I found no way to add a class_attribute using the .prepend mechanism.
  # Therefore, this module is .include'd instead of .prepend'd into its core counterpart.
  module Base
    extend ActiveSupport::Concern

    included do
      class_attribute :include_manageds
      self.include_manageds = false

      def add_config(permission, action, constraint)
        @store.add(AbilityDsl::Config.new(permission,
          @subject_class,
          action,
          @ability_class,
          constraint,
          {include_manageds: include_manageds}))
      end
    end
  end
end
