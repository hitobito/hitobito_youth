# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Alpen-Club. This file is part of
#  hitobito_sac_cas and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth

class Event::ParticipationButtons
  # defines state dependent rendering of buttons, i.e.
  # cancel button is only rendered if participation is in state assigned or applied
  class_attribute :conditions, default: {
    cancel: [:assigned, :applied],
    reject: [:applied],
    absent: [:assigned, :attended],
    attend: [:absent, if: -> { @event.closed? }],
    assign: [:absent, if: -> { !@event.closed? }]
  }

  class_attribute :i18n_keys, default: {
    attend: :attended,
    assign: :assigned
  }

  delegate :can?, :content_tag, :action_button, :render, :safe_join, to: "@template"

  def initialize(template, participation)
    @template = template
    @participation = participation
    @event = participation.event
  end

  def to_s
    buttons = build_buttons.compact
    content_tag(:div, safe_join(buttons))
  end

  private

  def build_buttons
    conditions.keys.map do |state|
      next unless show_button?(state)

      build_button(state)
    end
  end

  def build_button(to_state)
    return build_cancel_button if to_state == :cancel
    return build_reject_button if to_state == :reject

    build_action_button(to_state)
  end

  def build_cancel_button
    action_button(t(".cancel_button"),
      nil,
      :"times-circle",
      title: t(".cancel_title"),
      data: {
        bs_toggle: "popover",
        bs_placement: :bottom,
        bs_content: render("popover_cancel").to_str
      })
  end

  def build_reject_button
    build_action_button(:reject, :"thumbs-down")
  end

  def build_action_button(state, icon = :tag)
    path = :"#{state}_group_event_participation"
    action_button(label(state), path, icon, method: :put)
  end

  def show_button?(to_state)
    from_states = conditions[to_state]
    conditional = from_states.dup.extract_options![:if]

    if conditional.nil? || instance_exec(&conditional)
      participation_state_transition_allowed?(to_state, from_states)
    end
  end

  def label(state)
    prefix = i18n_keys.fetch(state, state)
    t(".#{prefix}_button")
  end

  def t(key)
    @template.t(key, i18n_scope: "events.participations.actions_show")
  end

  def participation_state_transition_allowed?(to_state, from_states)
    from_states.collect(&:to_s).include?(@participation.state) && can?(to_state, @participation)
  end
end
