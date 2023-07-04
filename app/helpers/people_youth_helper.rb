# encoding: utf-8

#  Copyright (c) 2012-2014, CEVI Regionalverband ZH-SH-GL. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

module PeopleYouthHelper

  def existing_person_nationalities
    Person.distinct.where('nationality IS NOT NULL').pluck(:nationality)
  end

  def format_person_readable_manageds(person)
    format_many_assoc(person, OpenStruct.new({ name: :readable_manageds }))
  end

end
