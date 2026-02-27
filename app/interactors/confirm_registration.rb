class ConfirmRegistration
  include Interactor

  def call
    phone_number = context.phone_number
    sms_code = context.sms_code
    normalized_phone = OtpCode.normalize_phone(phone_number)

    user = User.find_by(phone_number: normalized_phone, phone_verified: false)
    context.fail!(error: "No pending registration found for this phone number") unless user

    otp = OtpCode.for_phone(normalized_phone).active.last
    context.fail!(error: "OTP expired or not found. Please register again.") unless otp

    unless otp.valid_code?(sms_code)
      if otp.max_attempts_reached?
        context.fail!(error: "Maximum attempts reached. Please register again.")
      else
        context.fail!(error: "Invalid OTP code")
      end
    end

    otp.consume!
    user.update!(phone_verified: true)

    session = user.sessions.create!
    access_token = JwtService.encode_access_token({ user_id: user.id })

    context.user = user
    context.access_token = access_token
    context.refresh_token = session.refresh_token
  end
end
