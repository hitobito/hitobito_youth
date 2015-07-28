# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ParticipationsController
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :cancel, :reject

    alias_method_chain :build_application, :state
  end

  def cancel
    entry.canceled_at = params[:event_participation][:canceled_at]
    entry.state = 'canceled'
    if with_callbacks(:cancel) { entry.save }
      flash[:notice] ||= t('event.participations.canceled_notice', participant: entry.person)
    else
      flash[:alert] ||= entry.errors.full_messages
    end
    redirect_to group_event_participation_path(group, event, entry)
  end

  def reject
    entry.state = 'rejected'
    if with_callbacks(:reject) { entry.save }
      flash[:notice] ||= t('event.participations.rejected_notice', participant: entry.person)
    else
      flash[:alert] ||= entry.errors.full_messages
    end
    redirect_to group_event_participation_path(group, event, entry)
  end

  private

  def build_application_with_state(participation)
    build_application_without_state(participation)
    participation.state = new_record_for_someone_else?(participation) ? 'assigned' : 'applied'
  end

  def new_record_for_someone_else?(participation)
    participation.new_record? && participation.person != current_user
  end

end
