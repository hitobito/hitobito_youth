

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
