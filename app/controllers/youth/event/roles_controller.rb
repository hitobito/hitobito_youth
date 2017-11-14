# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::RolesController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :create, :tentative
  end

  private

  def create_with_tentative
    assign_attributes
    with_person_add_request do
      set_participation_active
      new_participation = entry.participation.new_record?
      created = with_callbacks(:create, :save) { save_entry }
      respond_with(entry, success: created, location: after_create_url(new_participation, created))
    end
  end

  def set_participation_active
    participation = entry.participation
    return unless participation.state == 'tentative'
    participation.active = true
    participation.state = 'assigned'
  end

end
