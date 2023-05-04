

module Youth::Event::RegisterController
  extend ActiveSupport::Concern

  included do
    helper_method :manager
  end

  def manager
    params[:manager]
  end
end
