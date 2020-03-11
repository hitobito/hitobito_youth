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
            alias_method_chain :for_user, :cancel
          end
        end

        module ClassMethods
          def for_user_with_cancel(template, group, event, user)
            participation = user_participation(event, user).first
            if participation && participation.state == 'canceled'
              new(template, group, event, I18n.t('event_decorator.canceled'), 'times-circle').
                disabled_button
            else
              for_user_without_cancel(template, group, event, user)
            end
          end

          def user_participation(event, user)
            event.participations.
              where(person_id: user.id).
              where.not(state: 'tentative')
          end

          def user_participates_in_with_tentative?(user, event)
            user_participation(event, user).exists?
          end
        end
      end
    end
  end
end
