# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Export::EventParticipationsExportJob
  extend ActiveSupport::Concern

  included do
    alias_method_chain :exporter, :ndbjs
  end

  private

  def exporter_with_ndbjs
    if @controller_params[:ndbjs] && user_ability.can?(:show_details, entries.first)
      Export::Tabular::People::ParticipationsNdbjs
    elsif @controller_params[:sportdb] && user_ability.can?(:show_details, entries.first)
      Export::Tabular::People::ParticipationsSportdb
    else
      exporter_without_ndbjs
    end
  end

  def user_ability
    @user_ability ||= Ability.new(user)
  end

end
