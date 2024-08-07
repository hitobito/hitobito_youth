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
              return new(template, group, event, I18n.t("event_decorator.apply"), :check).to_s
            end

            participation = user_participation(event, user).first
            if participation && participation.state == "canceled"
              new(template, group, event, I18n.t("event_decorator.canceled"), "times-circle")
                .disabled_button
            else
              for_user_without_cancel(template, group, event, user)
            end
          end

          def user_participation(event, user)
            event.participations
              .where(person_id: user.id)
              .where.not(state: "tentative")
          end

          def user_participates_in_with_tentative?(user, event)
            user_participation(event, user).exists?
          end
        end

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def init_items_with_manageds(url_options)
          return init_items_without_manageds(url_options) if url_options[:for_someone_else]
          return init_items_without_manageds(url_options) unless FeatureGate.enabled?("people.people_managers") # rubocop:disable Layout/LineLength

          template.current_user.and_manageds.each do |person|
            opts = url_options.clone
            opts[:person_id] = person.id unless template.current_user == person

            disabled_message = disabled_message_for_person(person)
            if disabled_message.present?
              add_disabled_item(person, disabled_message)
            elsif event.participant_types.size > 1
              item = add_item(person.full_name, "#")

              item.sub_items = participant_types_sub_items(opts)
            else
              add_participant_item(person, opts)
            end
          end

          if register_new_managed?
            opts = url_options.merge(event_role: {type: event.participant_types.first.sti_name})
            add_item(
              translate(".register_new_managed"),
              template.contact_data_managed_group_event_participations_path(group, event, opts)
            )
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def disabled_message_for_person(person)
          if ::Event::Participation.exists?(person: person, event: event)
            translate(:"disabled_messages.already_exists")
          elsif ::Ability.new(person).cannot?(:show, event)
            translate(:"disabled_messages.cannot_see_event")
          end
        end

        def add_disabled_item(person, message)
          add_item("#{person.full_name} (#{message})", "#", disabled_msg: message)
        end

        def add_participant_item(person, opts)
          opts = opts.merge(event_role: {type: event.participant_types.first.sti_name})
          link = participate_link(opts)
          add_item(person.full_name, link)
        end

        def participant_types_sub_items(opts)
          event.participant_types.map do |type|
            opts = opts.merge(event_role: {type: type.sti_name})
            link = participate_link(opts)
            ::Dropdown::Item.new(translate(:as, role: type.label), link)
          end
        end

        def register_new_managed?
          event.external_applications? &&
            FeatureGate.enabled?("people.people_managers.self_service_managed_creation")
        end
      end
    end
  end
end
