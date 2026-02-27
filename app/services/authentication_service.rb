class AuthenticationService
  class << self
    # Authenticate user from access token (used by UserAuthenticatable and AdminAuthenticatable)
    def authenticate_user(token)
      payload = JwtService.decode(token)
      User.find(payload[:user_id])
    rescue JwtService::TokenExpiredError, JwtService::InvalidTokenError, ActiveRecord::RecordNotFound
      nil
    end
  end
end
