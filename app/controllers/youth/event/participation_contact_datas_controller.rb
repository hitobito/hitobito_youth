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
    return super unless participation_for_managed?

    Event::ParticipationContactDatas::Managed
  end

  def permitted_attrs
    super + [:privacy_policy_accepted]
  end

  def person
    @person ||= entry&.person || params_person || current_user
  end

  def params_person
    current_user.manageds.find(params[:person_id]) if params[:person_id].present?
  end

  def participation_for_managed?
    current_user.manageds.include?(params_person)
  end

  def after_update_success_path
    new_group_event_participation_path(
      group,
      event,
      {event_role: {type: params[:event_role][:type]},
       event_participation: {person_id: entry.person.id}}
    )
  end

  def privacy_policy_param
    params.dig(contact_data_param_key, :privacy_policy_accepted)
  end

  def contact_data_param_key
    if participation_for_managed?
      :event_participation_contact_datas_managed
    else
      :event_participation_contact_data
    end
  end
end
