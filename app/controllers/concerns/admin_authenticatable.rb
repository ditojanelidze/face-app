module AdminAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    token = extract_token_from_header
    return render_unauthorized("Missing authorization token") unless token

    @current_admin = VenueAdminAuthenticationService.authenticate_admin(token)
    render_unauthorized("Invalid or expired token") unless @current_admin
  end

  def current_admin
    @current_admin
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
