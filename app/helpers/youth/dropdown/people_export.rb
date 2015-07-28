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
        alias_method_chain :csv_links, :ndbjs
      end

      def csv_links_with_ndbjs
        csv_links_without_ndbjs

        if @details && params[:controller] == 'event/participations'
          csv_path = params.merge(format: :csv)
          csv_item = @items.first
          csv_item.sub_items << ::Dropdown::Item.new(translate(:ndbjs), csv_path.merge(ndbjs: true))
          csv_item.sub_items << ::Dropdown::Item.new(translate(:sportdb), csv_path.merge(sportdb: true))
        end
      end

    end
  end
end
