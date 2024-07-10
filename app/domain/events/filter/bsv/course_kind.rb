# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Events::Filter::Bsv
  class CourseKind
    def initialize(_user, params, _options, scope)
      @params = params
      @scope = scope
    end

    def to_scope
      return @scope if kind_ids.blank?

      @scope.left_joins(:kind).where(event_kinds: {id: kind_ids})
    end

    private

    def kind_ids
      @kind_ids ||= (@params.dig(:filter, :kinds) || "").split(",")
    end
  end
end
