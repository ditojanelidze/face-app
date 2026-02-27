module AdminAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    token = extract_token_from_header
    return render_unauthorized("Missing authorization token") unless token

    user = AuthenticationService.authenticate_user(token)
    return render_unauthorized("Invalid or expired token") unless user
    return render_unauthorized("Venue admin access required") unless user.venue_admin?

    @current_user = user
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header.present?

    header.split(" ").last
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { error: message }, status: :unauthorized
  end
end
