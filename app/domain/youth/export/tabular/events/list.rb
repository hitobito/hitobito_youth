#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Export::Tabular::Events::List
  extend ActiveSupport::Concern

  included do
    alias_method_chain :data_rows, :counts
    alias_method_chain :row_for, :counts
    alias_method_chain :add_count_labels, :state
  end

  def data_rows_with_counts(format = nil, &) # rubocop:todo Metrics/AbcSize
    if model_class.supports_applications?
      @gender_counts ||= participant_counts(
        list.merge(Event::Participation.with_person_participants)
             .merge(Event::Participation.with_guest_participants)
             .where(event_participations: {active: true})
             # rubocop:todo Layout/LineLength
             .group("events.id", "CASE #{Event::Participation.quoted_table_name}.participant_type WHEN 'Event::Guest' THEN #{Event::Guest.quoted_table_name}.gender ELSE #{Person.quoted_table_name}.gender END")
        # rubocop:enable Layout/LineLength
      )
      @state_counts ||= participant_counts(
        list.where(event_participations: {state: model_class.revoked_participation_states})
             .group("events.id", "event_participations.state")
      )
    end

    data_rows_without_counts(format, &)
  end

  private

  def add_count_labels_with_state(labels)
    add_count_labels_without_state(labels)
    if model_class.supports_applications?
      labels[:male_count] = translate(:male_count)
      labels[:female_count] = translate(:female_count)
      labels[:canceled_count] = translate(:canceled_count)
      labels[:absent_count] = translate(:absent_count)
      labels[:rejected_count] = translate(:rejected_count)
    end
  end

  def row_for_with_counts(entry, format)
    row_class.new(entry, format, @gender_counts, @state_counts)
  end

  def participant_counts(scope)
    counts = scope.joins(participations: :roles)
      .where(event_roles: {type: model_class.participant_types.collect(&:sti_name)})
      .unscope(:order)
      .count("event_participations.id")

    Hash.new { |h, k| h[k] = Hash.new(0) }.tap do |hash|
      counts.each do |(event_id, group), count|
        hash[event_id][group] = count
      end
    end
  end
end
