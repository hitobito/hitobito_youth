# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Events::Filter::Bsv
  class Kind < Events::Filter::Base
    class << self
      def key
        "bsv_kind"
      end
    end

    self.permitted_args = [:ids]

    def apply(scope)
      scope.where(kind_id: kind_ids)
    end

    private

    def kind_ids
      Array(args[:ids]).compact_blank
    end
  end
end
