# frozen_string_literal: true

#  Copyright (c) 2025, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth
#  and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PaperTrail::VersionDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :association_change_text, :people_manager
  end

  def association_change_text_with_people_manager(changeset, item)
    unless people_manager_version?
      return association_change_text_without_people_manager(changeset, item)
    end

    # Since PeopleManager entries are either created or destroyed, accessing changes makes sense
    changes = object.send(:object_changes_deserialized)
    manager_id = changes["manager_id"].compact.first
    managed_id = changes["managed_id"].compact.first

    key, label = if manager_id == main_id
      ["managed", Person.find_by(id: managed_id)&.person_name]
    elsif managed_id == main_id
      ["manager", Person.find_by(id: manager_id)&.person_name]
    end

    I18n.t("version.association_change.#{item_class.name.underscore}.#{model.event}.#{key}",
      default: :"version.association_change.#{model.event}",
      model: item_class.model_name.human,
      label: label || "(#{I18n.t("version.association_change.deleted_person")})",
      changeset: changeset)
  end

  private

  def people_manager_version?
    item_type == PeopleManager.sti_name
  end
end
