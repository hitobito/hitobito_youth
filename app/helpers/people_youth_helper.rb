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
    manageds = person.decorate.readable_manageds
    if manageds.size.zero?
      ta(:no_entry, association(person, :readable_manageds))
    else
      simple_list(manageds, class: 'unstyled') { |val| assoc_link(val) }
    end
  end

  def format_person_managers(person)
    managers = person.managers
    if managers.size.zero?
      ta(:no_entry, association(person, :managers))
    else
      simple_list(managers, class: 'unstyled') { |val| assoc_link(val) }
    end
  end

end
