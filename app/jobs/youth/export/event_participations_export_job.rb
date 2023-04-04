# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Export::EventParticipationsExportJob
  extend ActiveSupport::Concern

  included do
    alias_method_chain :exporter, :nds
  end

  private

  def exporter_with_nds
    if @options[:nds_course] && ability.can?(:show_details, entries.first)
      Export::Tabular::People::ParticipationsNdsCourse
    elsif @options[:nds_camp] && ability.can?(:show_details, entries.first)
      Export::Tabular::People::ParticipationsNdsCamp
    else
      exporter_without_nds
    end
  end

end
