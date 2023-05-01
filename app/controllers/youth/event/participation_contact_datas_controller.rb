# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationContactDatasController
  private

  def contact_data_class
    return super unless current_user.manageds.include?(params_person)

    Event::ParticipationContactDatas::Managed
  end

  def person
    @person ||= entry&.person || params_person || current_user
  end

  def params_person
    return current_user.manageds.find(params[:person_id]) if params[:person_id].present?

    if params.dig(:event_participation_contact_data_managed, :email)
      return current_user.manageds.find_by(email: params.dig(:event_participation_contact_data_managed,
                                                             :email))
    end
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
