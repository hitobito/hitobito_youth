#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PersonDecorator
  extend ActiveSupport::Concern

  def translated_nationality_j_s
    return "" if nationality_j_s.blank?

    I18n.t("activerecord.attributes.person.nationalities_j_s.#{nationality_j_s}")
  end

  def readable_manageds
    manageds.select { |m| can?(:show, m) }
  end
end
