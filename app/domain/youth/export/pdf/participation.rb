#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Youth::Export::Pdf
  module Participation
    class PersonAndEvent < Export::Pdf::Participation::PersonAndEvent
      class Person < Export::Pdf::Participation::PersonAndEvent::Person
        def render
          super
          render_people_managers
        end

        def render_people_managers
          return unless FeatureGate.enabled?('people.people_managers')

          person.people_managers&.each do |manager|
            labeled_attr(manager, :manager)
          end
        end
      end
    end
  end
end
