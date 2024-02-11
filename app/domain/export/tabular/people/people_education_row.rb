# encoding: utf-8

#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::People
  class PeopleEducationRow < Export::Tabular::Row

    def event_participations
      today = Time.zone.today
      entry.event_participations.
        select do |p|
          p.event.supports_applications? &&
            p.event.dates.sort_by(&:start_at).last.start_at >= today
        end.
        collect do |p|
          p.event.name
        end.
        join(', ')
    end

    def qualifications
      entry.qualifications.
        select(&:reactivateable?).
        sort_by(&:start_at).
        reverse.
        uniq(&:qualification_kind).
        collect do |q|
          "#{q.qualification_kind.label}".strip
        end.
        join(', ')
    end

  end
end
