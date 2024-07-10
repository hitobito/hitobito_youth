#  Copyright (c) 2014-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Youth::PersonSerializer
  extend ActiveSupport::Concern

  included do
    extension(:details) do |options|
      map_properties :canton

      if options[:show_full]
        map_properties :j_s_number, :nationality_j_s, :ahv_number
      end
    end
  end
end
