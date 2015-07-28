# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::Course
  extend ActiveSupport::Concern

  included do
    class_attribute :tentative_states
    self.tentative_states = [:all]

    self.used_attributes += [:training_days, :tentative_applications]

    alias_method_chain :applicants_scope, :tentative
  end


  def tentative_application_possible?
    tentative_applications? && (tentative_states.include?(state) || tentative_states == [:all])
  end

  def tentatives_count
    participations.tentative.count
  end

  def organizers
    Person.
      includes(:roles).
      where(roles: { type: organizing_role_types,
                     group_id: groups.collect(&:id) })
  end

  private


  def applicants_scope_with_tentative
    applicants_scope_without_tentative.countable_applicants
  end

  def organizing_role_types
    ::Role.types_with_permission(:layer_full) +
    ::Role.types_with_permission(:layer_and_below_full)
  end

end
