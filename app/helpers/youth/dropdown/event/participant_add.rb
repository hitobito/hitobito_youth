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
            if user.manageds.any?
              return new(template, user, group, event, I18n.t('event_decorator.apply'), :check).to_s
            end

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
          return init_items_without_manageds(url_options) unless FeatureGate.enabled?('people.people_managers')  # rubocop:disable Metrics/LineLength

          [user, user.manageds].flatten.each do |person|
            opts = url_options.clone
            opts[:person_id] = person.id unless @user == person

            disabled_message = disabled_message_for_person(person)
            if disabled_message.present?
              add_disabled_item(person, disabled_message)
            else
              if event.participant_types.size > 1
                item = add_item(person.full_name, '#')

                item.sub_items = participant_types_sub_items(opts)
              else
                add_participant_item(person, opts)
              end
            end
          end
        end

        def disabled_message_for_person(person)
          if ::Ability.new(user).cannot?(:create, ::Event::Participation.new(person: person,
                                                                               event: event))
            translate(:'disabled_messages.not_allowed')
          elsif ::Event::Participation.exists?(person: person, event: event)
            translate(:'disabled_messages.already_exists')
          end
        end

        def add_disabled_item(person, message)
          add_item("#{person.full_name} (#{message})", '#', disabled_msg: message)
        end

        def add_participant_item(person, opts)
          opts = opts.merge(event_role: { type: event.participant_types.first.sti_name })
          link = participate_link(opts)
          add_item(person.full_name, link)
        end

        def participant_types_sub_items(opts)
          event.participant_types.map do |type|
            opts = opts.merge(event_role: { type: type.sti_name })
            link = participate_link(opts)
            ::Dropdown::Item.new(translate(:as, type.label), link)
          end
        end
      end
    end
  end
end
