# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Csv::Events
  class BsvRow < Export::Csv::Row

    def vereinbarungs_id_fiver
      entry.kind.vereinbarungs_id_fiver
    end

    def kurs_id_fiver
      kurs_id_fiver = entry.kind.kurs_id_fiver
      kurs_id_fiver.truncate(100) unless kurs_id_fiver.blank?
    end

    def oldest_event_date
      date = entry.dates.order(:start_at).try(:first)
      date && date.start_at.strftime('%d.%m.%Y')
    end

    def location
      location = entry.location
      location.truncate(200) if location.present?
    end

    def training_days
      days = entry.training_days
      (days * 2).round / 2.0 if days.present?
    end

    def participant_count
      active_participants_between_17_and_30.count
    end

    def leader_count
      leaders.count
    end

    def canton_count
      cantons.size
    end

    def languages_count
      1
    end

    private
    def active_participants_between_17_and_30
      entry.participations.
        active.
        joins(:roles).
        joins(:person).
        where({ event_roles: { type: "Event::Course::Role::Participant"}}).
        where({ people: { birthday: participant_min_birthday..participant_max_birthday }})
    end

    def participant_min_birthday
      Date.new(y=current_year-30, m=12, d=31)
    end

    def participant_max_birthday
      Date.new(y=current_year-17, m=12, d=31)
    end

    def current_year
      Date.today.year
    end

    def leaders
      entry.participations.
        joins(:roles).
        where({ event_roles: { type: leader_roles }})
    end

    def leader_roles
      [ 'Event::Role::Leader',
        'Event::Role::Cook'
      ]
    end

    def cantons
      active_participants_between_17_and_30.collect do |p|
        p.person.canton
      end.compact.uniq
    end

  end
end
