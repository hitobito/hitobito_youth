
module Youth::Event::ParticipationContactDatasController
  def person
    @person ||= entry&.person || params_person || current_user
  end

  def params_person
    return current_user.manageds.find(params[:person_id]) if params[:person_id]
    return current_user.manageds.find_by(email: params.dig(:event_participation_contact_data, :email)) if params.dig(:event_participation_contact_data, :email)
  end

  def after_update_success_path
    new_group_event_participation_path(
      group,
      event,
      { event_role: { type: params[:event_role][:type] },
        event_participation: { person_id: entry.person.id } }
    )
  end
end
