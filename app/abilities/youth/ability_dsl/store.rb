# frozen_string_literal: true

# Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
# hitobito_youth and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https ://github.com/hitobito/hitobito_youth.

# Extends the ability store from the core with the possibility to filter the
# stored ability configs and keep only the ones which a manager can inherit from their
# manageds (children).
module Youth::AbilityDsl::Store
  def only_manager_inheritable
    filtered_configs = configs.select { |_, config| config.options[:include_manageds] }
    AbilityDsl::Store.new.tap do |clone|
      clone.instance_variable_set(:@ability_classes, ability_classes)
      clone.instance_variable_set(:@configs, filtered_configs)
    end
  end
end
