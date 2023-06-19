# encoding: utf-8

#  Copyright (c) 2012-2014, CEVI Regionalverband ZH-SH-GL. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

module PeopleYouthHelper

  def existing_person_nationalities
    Person.distinct.where('nationality IS NOT NULL').pluck(:nationality)
  end

  def render_manageds(person)
    readable_manageds = person.manageds.select { |m| can?(:show, m) }
    return ta('no_entry') if readable_manageds.blank?

    content_tag(:ul) do
      safe_join(readable_manageds.map do |managed|
        content_tag(:li) do
          can?(:update, managed) ? link_to(managed, managed) : managed.to_s
        end
      end)
    end
  end

end
