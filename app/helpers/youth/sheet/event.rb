#  Copyright (c) 2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Sheet::Event
  extend ActiveSupport::Concern

  included do
    tabs.insert(
      -2,
      Sheet::Tab.new("events.tabs.tentatives",
        :group_event_tentatives_path,
        if: :list_tentatives)
    )
  end
end
