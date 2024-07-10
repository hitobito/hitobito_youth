# frozen_string_literal: true

# Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
# hitobito_youth and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https ://github.com/hitobito/hitobito_youth.

# Extends the ability configs from core with the possibility
# to add options.
module Youth::AbilityDsl::Config
  attr_reader :options

  def initialize(permission, subject_class, action, ability_class, constraint, options = {})
    super(permission, subject_class, action, ability_class, constraint)
    @options = options
  end
end
