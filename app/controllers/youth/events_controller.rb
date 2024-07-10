# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::EventsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :load_user_participation, :manageds
    alias_method_chain :load_my_invitation, :manageds
  end

  def load_user_participation_with_manageds
    @user_participations = current_user&.and_manageds&.map do |person|
      person.event_participations.find_by(event_id: entry.id)
    end&.compact

    load_user_participation_without_manageds
  end

  def load_my_invitation_with_manageds
    @invitations = current_user&.and_manageds&.map do |person|
      person.event_invitations.find_by(event_id: entry.id)
    end&.compact

    @open_invitations = @invitations.select do |invitation|
      invitation.status == :open &&
        event_user_application_possible?(invitation.person)
    end.compact

    @declined_invitations = @invitations.select do |invitation|
      invitation.status == :declined
    end.compact

    load_my_invitation_without_manageds
  end

  def event_user_application_possible?(person = current_user)
    participation = entry.participations.new
    participation.person = person

    entry.application_possible? && can?(:new, participation)
  end
end
