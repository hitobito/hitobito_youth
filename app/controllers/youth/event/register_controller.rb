# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::RegisterController
  extend ActiveSupport::Concern

  included do
    helper_method :manager

    alias_method_chain :registered_notice, :manager
  end

  def registered_notice_with_manager
    manager ? translate(:registered_manager) : registered_notice_without_manager
  end

  def manager
    @manager ||= params[:manager]
  end
end
