#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationFilter
  extend ActiveSupport::Concern

  included do
    self.load_entries_includes += [:application]

    alias_method_chain :predefined_filters, :revoked
    alias_method_chain :apply_filter_scope, :revoked
  end

  def predefined_filters_with_revoked
    @predefined_filters ||=
      predefined_filters_without_revoked.dup.tap do |predefined|
        if event.revoked_participation_states.present? &&
            Ability.new(user).can?(:index_revoked_participations, event)
          predefined << "revoked"
        end
      end
  end

  private

  def apply_filter_scope_with_revoked(records, kind = params[:filter])
    if kind == "revoked" && predefined_filters.include?("revoked")
      event.participations
        .joins(:roles)
        .where("event_roles.type" => event.participant_types.collect(&:sti_name))
        .where("event_participations.state" => event.revoked_participation_states)
        .includes(load_entries_includes)
        .distinct
    else
      apply_filter_scope_without_revoked(records, kind)
    end
  end
end
