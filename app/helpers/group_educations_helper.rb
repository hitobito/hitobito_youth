# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module GroupEducationsHelper

  def joined_qualification_kind_labels(person)
    person.qualifications.
      select(&:reactivateable?).
      sort_by(&:start_at).
      reverse.
      uniq(&:qualification_kind).
      collect do |q|     
        format_qualification_label(q)
      end.
      join('<br/>')
  end

  def joined_event_participations(person)
    today = Time.zone.today
    person.event_participations.
      select do |p|
        p.event.supports_applications? &&
          p.event.dates.sort_by(&:start_at).last.start_at >= today
      end.
      collect do |p|
        format_open_participation_event(p)
      end.
      join(', ')
  end

  def format_open_participation_event(participation)
    event = participation.event
    if participation.state == 'tentative'
      link_to(event.name,
              [event.groups.first, event],
              style: 'padding-right: 0.3em') +
             badge('?', 'warning', t('.tentative_participation'))
    else
      link_to(event.name, [event.groups.first, event])
    end
  end

  def format_qualification_label(q)
    label = q.qualification_kind.label 
    if q.active?
      if q.finish_at.year == Time.now.year
        content_tag(:span, label + " " + format_attr(q, :finish_at), class: 'text-warning')
      else
        label + " " + format_attr(q, :finish_at)
      end
    else
      content_tag(:span, label, class: 'muted')
    end
  end

end
