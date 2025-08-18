#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Export::EventParticipationsExportJob
  private

  def exporter
    if @options[:nds_course] && ability.can?(:show_details, entries.build)
      Export::Tabular::People::ParticipationsNdsCourse
    elsif @options[:nds_camp] && ability.can?(:show_details, entries.build)
      Export::Tabular::People::ParticipationsNdsCamp
    elsif @options[:slrg] && ability.can?(:show_details, entries.build)
      Export::Tabular::People::ParticipationsSlrgList
    else
      super
    end
  end
end
