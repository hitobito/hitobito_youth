#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::Participation
  extend ActiveSupport::Concern

  included do
    ### VALIDATIONS

    validates :state,
      inclusion: {in: ->(p) { p.event.possible_participation_states }},
      if: :states?
    validates :canceled_at,
      presence: true,
      if: ->(p) { p.event.is_a?(Event::Course) && p.state == "canceled" }

    ### CALLBACKS

    before_validation :set_default_state, if: :states?
    before_validation :delete_tentatives,
      if: ->(p) { p.event.is_a?(Event::Course) && p.state != "tentative" },
      on: :create
    before_validation :set_active_based_on_state, if: :states?
    before_validation :clear_canceled_at, unless: ->(p) { p.state == "canceled" }
    after_update :update_participant_count, if: :state_changed?

    alias_method_chain :applying_participant?, :tentative

    class << self
      def pending
        where(active: false).where.not(state: "canceled").or(where(state: nil))
      end
    end
  end

  def states?
    event.possible_participation_states.present?
  end

  def applying_participant_with_tentative?
    applying_participant_without_tentative? && state != "tentative"
  end

  private

  def set_default_state
    self.state ||= event.default_participation_state(self)
  end

  # custom join event belongs_to kind is not defined in core
  def delete_tentatives
    return if person.nil? || event.nil?

    person.event_participations
      .joins("INNER JOIN events ON events.id = event_participations.event_id")
      .joins("INNER JOIN event_kinds ON event_kinds.id = events.kind_id")
      .where(state: "tentative",
        events: {kind_id: event.kind_id})
      .destroy_all
  end

  def set_active_based_on_state
    self.active = event.active_participation_states.include?(state)
    true
  end

  def clear_canceled_at
    self.canceled_at = nil
    true
  end
end
