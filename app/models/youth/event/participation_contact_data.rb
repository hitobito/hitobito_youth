# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationContactData
  extend ActiveSupport::Concern

  included do
    Event::ParticipationContactData.contact_attrs << :nationality_j_s << :ahv_number << :j_s_number
    delegate(*Event::ParticipationContactData.contact_attrs, to: :person)
  end

end
