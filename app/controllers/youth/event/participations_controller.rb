# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Youth::Event::ParticipationsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :exporter, :ndbjs
  end

  def exporter_with_ndbjs
    if params[:ndbjs] && can?(:show_details, entries.first)
      Export::Csv::People::ParticipationsNdbjs
    elsif params[:sportdb] && can?(:show_details, entries.first)
      Export::Csv::People::ParticipationsSportdb
    else
      exporter_without_ndbjs
    end
  end

end
