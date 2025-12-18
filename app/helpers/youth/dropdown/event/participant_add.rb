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
            if participation&.state == "canceled" && !adding_managed_possible?(user, event)
              new(template, group, event, I18n.t("event_decorator.canceled"), "times-circle")
                .disabled_button
            else
              for_user_without_cancel(template, group, event, user)
            end
          end

          def user_participation(event, user)
            event.participations
              .where(participant_id: user.id, participant_type: ::Person.sti_name)
              .where("state IS NULL OR state != 'tentative'")
          end

          def user_participates_in_with_tentative?(user, event)
            user_participation(event, user).exists?
          end
        end

        def participant_types_sub_items(opts)
          event.participant_types.map do |type|
            opts = opts.merge(event_role: {type: type.sti_name})
            link = participate_link(opts)
            ::Dropdown::Item.new(translate(:as, role: type.label), link)
          end
        end
      end
    end
  end
end
