class AuthenticationService
  class << self
    # Request OTP for phone number (for both registration and login)
    def request_otp(phone_number)
      normalized_phone = OtpCode.normalize_phone(phone_number)

      # Generate OTP
      otp = OtpCode.generate_for(normalized_phone)

      # Send SMS
      SmsService.send_otp(normalized_phone, otp.code)

      { success: true, message: "OTP sent successfully" }
    rescue SmsService::SmsDeliveryError => e
      { success: false, error: e.message }
    end

    # Verify OTP for registration (creates new user)
    def verify_registration(phone_number:, code:, first_name:, last_name:)
      normalized_phone = OtpCode.normalize_phone(phone_number)

      # Check if user already exists
      if User.exists?(phone_number: normalized_phone)
        return { success: false, error: "User already exists with this phone number" }
      end

      # Find and validate OTP
      otp = OtpCode.for_phone(normalized_phone).active.last
      return { success: false, error: "No valid OTP found" } unless otp

      unless otp.valid_code?(code)
        if otp.max_attempts_reached?
          return { success: false, error: "Maximum attempts reached. Please request a new OTP." }
        end
        return { success: false, error: "Invalid OTP code" }
      end

      # Create user
      user = User.new(
        first_name: first_name,
        last_name: last_name,
        phone_number: normalized_phone,
        phone_verified: true
      )

      unless user.save
        return { success: false, error: user.errors.full_messages.join(", ") }
      end

      # Consume OTP
      otp.consume!

      # Create session and generate tokens
      session = user.sessions.create!
      access_token = JwtService.encode_access_token({ user_id: user.id })

      {
        success: true,
        user: user,
        access_token: access_token,
        refresh_token: session.refresh_token
      }
    end

    # Verify OTP for login (existing user)
    def verify_login(phone_number:, code:, device_info: nil)
      normalized_phone = OtpCode.normalize_phone(phone_number)

      # Find user
      user = User.find_by(phone_number: normalized_phone)
      return { success: false, error: "User not found" } unless user

      # Find and validate OTP
      otp = OtpCode.for_phone(normalized_phone).active.last
      return { success: false, error: "No valid OTP found" } unless otp

      unless otp.valid_code?(code)
        if otp.max_attempts_reached?
          return { success: false, error: "Maximum attempts reached. Please request a new OTP." }
        end
        return { success: false, error: "Invalid OTP code" }
      end

      # Consume OTP
      otp.consume!

      # Create session and generate tokens
      session = user.sessions.create!(device_info: device_info)
      access_token = JwtService.encode_access_token({ user_id: user.id })

      {
        success: true,
        user: user,
        access_token: access_token,
        refresh_token: session.refresh_token
      }
    end

    # Refresh access token using refresh token
    def refresh_access_token(refresh_token)
      session = Session.find_by(refresh_token: refresh_token)

      return { success: false, error: "Invalid refresh token" } unless session
      return { success: false, error: "Session expired" } if session.expired?

      # Generate new access token
      access_token = JwtService.encode_access_token({ user_id: session.user_id })

      {
        success: true,
        access_token: access_token,
        refresh_token: session.refresh_token
      }
    end

    # Logout - invalidate session
    def logout(refresh_token)
      session = Session.find_by(refresh_token: refresh_token)
      session&.destroy

      { success: true, message: "Logged out successfully" }
    end

    # Authenticate user from access token
    def authenticate_user(token)
      payload = JwtService.decode(token)
      User.find(payload[:user_id])
    rescue JwtService::TokenExpiredError, JwtService::InvalidTokenError, ActiveRecord::RecordNotFound
      nil
    end
  end
end
