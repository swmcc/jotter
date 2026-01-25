class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Skip CSRF verification for API requests using token authentication
  skip_before_action :verify_authenticity_token, if: :api_request?

  private

  def api_request?
    request.format.json? && request.headers["Authorization"].present?
  end
end
