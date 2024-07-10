#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PeopleFiltersController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :people_list_path, :education
  end

  def people_list_path_with_education(options = {})
    if params[:education] == "true"
      educations_path(group, options)
    else
      people_list_path_without_education(options)
    end
  end
end
