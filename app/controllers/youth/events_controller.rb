

module Youth::EventsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :load_user_participation, :manageds
    alias_method_chain :load_my_invitation, :manageds
  end

  def load_user_participation_with_manageds
    @user_participation = @user_participations = [current_user, current_user&.manageds].flatten.map do |person|
      person.event_participations.find_by(event_id: entry.id)
    end.compact
  end

  def load_my_invitation_with_manageds
    @invitations = [current_user, current_user&.manageds].flatten.map do |person|
      person.event_invitations.find_by(event_id: entry.id)
    end
  end
end
