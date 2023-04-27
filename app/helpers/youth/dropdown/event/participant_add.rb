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

          alias_method_chain :init_items, :manageds
        end

        module ClassMethods
          def for_user_with_cancel(template, group, event, user)
            return new(template, user, group, event, I18n.t('event_decorator.apply'), :check).to_s if user.manageds.any?

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

        def init_items_with_manageds(url_options)
          [user, user.manageds].flatten.each do |person|
            opts = url_options.clone
            opts[:person_id] = person.id unless person == user

            disabled_message = disabled_message_for_person(person)
            if disabled_message.nil?
              if event.participant_types.size > 1
                item = add_item(person.full_name, '#')

                item.sub_items = event.participant_types.map do |type|
                  opts = opts.merge(event_role: { type: type.sti_name })
                  link = participate_link(opts)
                  ::Dropdown::Item.new(translate(:as, type.label), link)
                end
              else
                opts = opts.merge(event_role: { type: event.participant_types.first.sti_name })
                link = participate_link(opts)
                item = add_item(person.full_name, link)
              end
            else
              add_item("#{person.full_name} (#{disabled_message})", '#', disabled_msg: disabled_message)
            end
          end
        end

        def disabled_message_for_person(person)
          disabled_message = translate(:'disabled_messages.not_allowed') unless ::Ability.new(person).can?(:create, ::Event::Participation.new(person: person, event: event))
          disabled_message ||= translate(:'disabled_messages.already_exists') if ::Event::Participation.exists?(person: person, event: event)
          disabled_message
        end
      end
    end
  end
end
