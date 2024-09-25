#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationsController
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :cancel, :reject, :attend, :absent, :assign

    alias_method_chain :set_active, :state
    alias_method_chain :person_id, :managed
    alias_method_chain :return_path, :managed
    alias_method_chain :after_destroy_path, :managed
    alias_method_chain :set_success_notice, :managed

    def current_user_interested_in_mail?
      # send email to kind and verwalter
      associated_people = current_user.and_manageds.concat(current_user.managers)
      associated_people.map(&:id).include? entry.person_id
    end
  end

  def cancel
    entry.canceled_at = params[:event_participation][:canceled_at]
    change_state("canceled", "cancel")
  end

  def reject
    change_state("rejected", "reject")
  end

  def absent
    change_state("absent", "absent")
  end

  def attend
    change_state("attended", "attend")
  end

  def assign
    change_state("assigned", "assign")
  end

  private

  def change_state(state, callback_name)
    entry.state = state
    if with_callbacks(callback_name) { entry.save }
      flash[:notice] ||= t("event.participations.#{state}_notice", participant: entry.person)
    else
      flash[:alert] ||= entry.errors.full_messages
    end
    redirect_to group_event_participation_path(group, event, entry)
  end

  def set_active_with_state
    set_active_without_state
    entry.state = event.default_participation_state(entry, new_record_for_someone_else?)
  end

  def new_record_for_someone_else?
    entry.new_record? && entry.person != current_user && params[:for_someone_else]
  end

  def person_id_with_managed
    if model_params&.key?(:person_id) && own_or_managed_params_person?
      model_params[:person_id]
    else
      person_id_without_managed
    end
  end

  def return_path_with_managed
    if manager_via_public_event? || (participation_of_managed? && !entry.persisted?)
      group_event_path(group, event)
    else
      return_path_without_managed
    end
  end

  def after_destroy_path_with_managed
    if participation_of_managed?
      group_event_path(group, event)
    else
      after_destroy_path_without_managed
    end
  end

  def set_success_notice_with_managed
    if !entry.pending? && manager_via_public_event?
      flash[:notice] ||= translate(:success_for_external_manager,
        full_entry_label: full_entry_label)
    else
      set_success_notice_without_managed
    end
  end

  def manager_via_public_event?
    participation_of_managed? && current_user.roles.none?
  end

  def participation_of_managed?
    current_user.manageds.include?(entry.person)
  end

  def own_or_managed_params_person?
    model_params[:person_id].to_i == current_user.id ||
      current_user.manageds.pluck(:id).include?(model_params[:person_id].to_i)
  end
end
