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
        label = "#{h(q.qualification_kind.label)} #{format_attr(q, :finish_at)}".strip
        content_tag(:span, label, class: qualification_label_class(q))
      end.
      join('<br/>').
      html_safe
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
      join(', ').
      html_safe
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

  def qualification_label_class(qualification)
    if !qualification.active?
      'muted'
    elsif qualification.finish_at && qualification.finish_at.year == Time.zone.now.year
      'text-warning'
    end
  end

end
