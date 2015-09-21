# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth
  module Dropdown
    module Event
      module ParticipantAdd
        extend ActiveSupport::Concern

        included do
          class << self
            alias_method_chain :user_participates_in?, :tentative
          end
        end

        module ClassMethods
          def user_participates_in_with_tentative?(user, event)
            event.participations.
              where(person_id: user.id).
              where.not(state: 'tentative').
              exists?
          end
        end
      end
    end
  end
end
