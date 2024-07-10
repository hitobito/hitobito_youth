#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Youth
  module Dropdown
    module PeopleExport
      def tabular_links(format)
        super.tap do |item|
          if @details && params[:controller] == "event/participations"
            path = params.merge(format: format)
            event = template.entry.event

            add_camp_items(item, path) if is_camp?(event)
            add_course_items(item, path) if is_course?(event)
          end
        end
      end

      def is_course?(event)
        # Meant to be overridden in more specific wagon
        true
      end

      def is_camp?(event)
        # Meant to be overridden in more specific wagon
        true
      end

      def add_camp_items(item, path)
        item.sub_items <<
          ::Dropdown::Item.new(translate(:nds_camp), path.merge(nds_camp: true))
      end

      def add_course_items(item, path)
        item.sub_items <<
          ::Dropdown::Item.new(translate(:nds_course), path.merge(nds_course: true)) <<
          ::Dropdown::Item.new(translate(:slrg), path.merge(slrg: true))
      end
    end
  end
end
