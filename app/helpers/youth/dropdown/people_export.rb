# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Youth
  module Dropdown
    module PeopleExport
      extend ActiveSupport::Concern
      included do
        alias_method_chain :tabular_links, :nds
      end

      def tabular_links_with_nds(format)
        tabular_links_without_nds(format)

        if @details && params[:controller] == 'event/participations'
          path = params.merge(format: format)
          item = @items.find { |i| i.label == translate(format) }
          item.sub_items <<
            ::Dropdown::Item.new(translate(:nds_course), path.merge(nds_course: true)) <<
            ::Dropdown::Item.new(translate(:nds_camp), path.merge(nds_camp: true))
        end
      end

    end
  end
end
