# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Messages::BulkMail::AddressList
  extend ActiveSupport::Concern

  included do
    def people
      @people + Person.joins(:people_manageds)
                      .where(people_manageds: { managed: @people })
    end
  end
end
