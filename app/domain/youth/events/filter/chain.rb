# frozen_string_literal: true

#  Copyright (c) 2025, Schweizer Alpen-Club. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Events::Filter::Chain
  extend ActiveSupport::Concern

  included do
    self.types += [
      Events::Filter::Bsv::DateRange,
      Events::Filter::Bsv::Kind
    ]
  end
end
