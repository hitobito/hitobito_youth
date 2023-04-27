

module Youth::EventsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :load_user_participation, :manageds
    alias_method_chain :load_my_invitation, :manageds
  end

  def load_user_participation_with_manageds
    @user_participations = [current_user, current_user&.manageds].flatten.map do |person|
      person.event_participations.find_by(event_id: entry.id)
    end.compact
  end

  def load_my_invitation_with_manageds
    @invitations = [current_user, current_user&.manageds].flatten.map do |person|
      person.event_invitations.find_by(event_id: entry.id)
    end.compact

    @open_invitations = @invitations.select do |invitation|
      invitation.status == :open &&
        event_user_application_possible?(invitation.person)
    end.compact

    @declined_invitations = @invitations.select do |invitation|
      invitation.status == :declined
    end.compact
  end

  def event_user_application_possible?(person = current_user)
    participation = entry.participations.new
    participation.person = person

    entry.application_possible? && can?(:new, participation)
  end

end
