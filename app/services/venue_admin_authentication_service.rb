class VenueAdminAuthenticationService
  class << self
    def login(email:, password:)
      admin = VenueAdmin.find_by(email: email.downcase)

      unless admin&.authenticate(password)
        return { success: false, error: "Invalid email or password" }
      end

      access_token = JwtService.encode_admin_access_token({
        admin_id: admin.id,
        role: "venue_admin"
      })

      {
        success: true,
        admin: admin,
        access_token: access_token
      }
    end

    def authenticate_admin(token)
      payload = JwtService.decode(token)

      return nil unless payload[:role] == "venue_admin"

      VenueAdmin.find(payload[:admin_id])
    rescue JwtService::TokenExpiredError, JwtService::InvalidTokenError, ActiveRecord::RecordNotFound
      nil
    end
  end
end
