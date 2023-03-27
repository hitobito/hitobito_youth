# encoding: utf-8

#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::People
  class PeopleEducationList < Export::Tabular::Base

    self.model_class = ::Person
    self.row_class = PeopleEducationRow

    def attribute_labels
      { first_name: human_attribute(:first_name),
        last_name: human_attribute(:last_name),
        nickname: human_attribute(:nickname),
        email: human_attribute(:email),
        birthday: human_attribute(:birthday),
        qualifications: Qualification.model_name.human(count: 2),
        event_participations: Event::Application.model_name.human(count: 2) }
    end

  end
end
