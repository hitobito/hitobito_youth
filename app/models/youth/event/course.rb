# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::Course
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:training_days, :tentative_applications]

    # states are used for workflow
    # translations in config/locales
    self.possible_states = %w(created confirmed application_open application_closed
                              assignment_closed canceled completed closed)

    class_attribute :tentative_states
    self.tentative_states = %w(created confirmed)

    self.possible_participation_states =
      %w(tentative applied assigned rejected canceled attended absent)

    self.active_participation_states = %w(assigned attended)

    self.revoked_participation_states = %w(rejected canceled absent)

    self.countable_participation_states = %w(applied assigned attended absent)


    ### VALIDATIONS

    validates :state, inclusion: { in: ->(_) { possible_states } }


    ### CALLBACKS

    before_save :update_attended_participants_state, if: -> { state_changed?(to: 'closed') }
    before_save :update_assigned_participants_state, if: -> { changed_state_from_closed? }

    alias_method_chain :qualifications_visible?, :state


    # Define methods to query if a course is in the given state.
    # eg course.canceled?
    possible_states.each do |state|
      define_method "#{state}?" do
        self.state == state
      end
    end
  end

  # may participants apply now?
  def application_possible?
    application_open? &&
    (!application_opening_at || application_opening_at <= ::Time.zone.today)
  end

  def qualification_possible?
    !completed? && !closed?
  end

  # True when qualifications are ready to be displayed to participants.
  # Overridden in wagons
  def qualifications_visible_with_state?
    qualifying? && (completed? || closed?)
  end

  def state
    super || possible_states.first
  end

  def tentative_application_possible?
    tentative_applications? && (tentative_states.include?(state) || tentative_states == [:all])
  end

  def tentatives_count
    participations.tentative.count
  end

  def organizers
    Person.
      includes(:roles).
      where(roles: { type: organizing_role_types,
                     group_id: groups.collect(&:id) })
  end

  def default_participation_state(participation, for_someone_else = false)
    participation.application.blank? || for_someone_else ? 'assigned' : 'applied'
  end

  private

  def changed_state_from_closed?
    changed_attributes['state'] == 'closed'
  end

  def update_attended_participants_state
    participants_scope.where(state: 'assigned').update_all(state: 'attended')
  end

  def update_assigned_participants_state
    participants_scope.where(state: 'attended').update_all(state: 'assigned')
  end

  def organizing_role_types
    ::Role.types_with_permission(:layer_full) +
    ::Role.types_with_permission(:layer_and_below_full)
  end

  module ClassMethods
    def application_possible
      where(state: 'application_open')
        .where('events.application_opening_at IS NULL OR events.application_opening_at <= ?',
               ::Time.zone.today)
    end
  end
end
