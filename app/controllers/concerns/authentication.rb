module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie || find_session_by_api_token
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def find_session_by_api_token
      return nil unless request.headers["Authorization"].present?

      token = request.headers["Authorization"].to_s.split(" ").last
      api_token = ApiToken.find_by(token: token)

      if api_token
        api_token.touch_last_used!
        # Create a virtual session-like object for API requests
        @current_api_token = api_token
        VirtualSession.new(api_token.user)
      end
    end

    def request_authentication
      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        session[:return_to_after_authenticating] = request.url
        redirect_to new_session_path
      end
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || dashboard_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
