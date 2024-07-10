# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Youth::Events::FilteredList
  def filter_scopes
    return super if params.dig(:filter, :bsv_since).blank?

    filters = [Events::Filter::Bsv::DateRange] + super
    filters.prepend(Events::Filter::Bsv::CourseKind) if kind_used?
    filters.delete(Events::Filter::DateRange)
    filters.delete(Events::Filter::Groups)

    filters
  end
end
