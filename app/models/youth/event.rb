# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event
  extend ActiveSupport::Concern

  included do
    # participation states are used for workflow
    # translations in config/locales
    class_attribute :possible_participation_states
    self.possible_participation_states = []

    # all participations states the are considered as an active participation
    class_attribute :active_participation_states
    self.active_participation_states = []

    # all participations states that appear in the revoked tab
    class_attribute :revoked_participation_states
    self.revoked_participation_states = []

    # all participations states that are counted as applicants
    class_attribute :countable_participation_states
    self.countable_participation_states = []

    alias_method_chain :applicants_scope, :states
  end

  def default_participation_state(_participation)
    possible_participation_states.first
  end

  def applicants_scope_with_states
    # required for migrations
    if Event::Participation.column_names.include?('state') && possible_participation_states.present?
      applicants_scope_without_states.where(state: countable_participation_states)
    else
      applicants_scope_without_states
    end
  end

end
