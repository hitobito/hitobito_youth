# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationsController
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :cancel, :reject, :attend, :absent, :assign

    alias_method_chain :build_application, :state
    alias_method_chain :exporter, :ndbjs
  end

  def cancel
    entry.canceled_at = params[:event_participation][:canceled_at]
    change_state('canceled', 'cancel')
  end

  def reject
    change_state('rejected', 'reject')
  end

  def absent
    change_state('absent', 'absent')
  end

  def attend
    change_state('attended', 'attend')
  end

  def assign
    change_state('assigned', 'assign')
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

  def build_application_with_state(participation)
    build_application_without_state(participation)
    participation.state = new_record_for_someone_else?(participation) ? 'assigned' : 'applied'
  end

  def new_record_for_someone_else?(participation)
    participation.new_record? && participation.person != current_user
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
