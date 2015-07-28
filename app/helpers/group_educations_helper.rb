# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module GroupEducationsHelper

  def joined_qualification_kind_labels(person)
    person.qualifications.map do |qualification|
      qualification.qualification_kind.label
    end.join(', ')
  end

  def joined_event_participations(person)
    person.event_participations.
      select  { |p| p.course? && p.event.dates.last.start_at >= Date.today }.
      collect { |p| format_open_participation_event(p) }.
      join(', ')
  end

  def format_open_participation_event(participation)
    event = participation.event
    if participation.tentative?
      link_to(event.name,
              [event.groups.first, event],
              style: 'padding-right: 0.3em') +
             badge('?', 'warning', t('.tentative_participation'))
    else
      link_to(event.name, [event.groups.first, event])
    end
  end

end
