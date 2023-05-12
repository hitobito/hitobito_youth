# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationContactDatasController
  def person
    @person ||= entry&.person || params_person || current_user
  end

  def params_person
    current_user.manageds.find(params[:person_id]) if params[:person_id]
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
