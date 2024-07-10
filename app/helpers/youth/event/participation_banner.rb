# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

# It's safe to use instance variables here because they
# are encapsulated within their own class.
# rubocop:disable Rails/HelperInstanceVariable
module Youth::Event::ParticipationBanner
  def status_text
    key = if waiting_list?
      "waiting_list"
    elsif pending?
      "pending"
    else
      "explanation"
    end

    if @user_participation.person != @context.current_user
      key = ["managed", key].join(".")
    end

    t(key,
      person: @user_participation.person.full_name,
      scope: "event.participations.cancel_application")
  end
end
# rubocop:enable Rails/HelperInstanceVariable
