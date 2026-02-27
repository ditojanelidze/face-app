class ConfirmLogin
  include Interactor

  def call
    normalized_phone = OtpCode.normalize_phone(context.phone_number)

    user = User.find_by(phone_number: normalized_phone)
    context.fail!(error: "Account not found. Please register first.") unless user

    otp = OtpCode.for_phone(normalized_phone).active.last
    context.fail!(error: "OTP expired or not found. Please request a new code.") unless otp

    unless otp.valid_code?(context.sms_code)
      if otp.max_attempts_reached?
        context.fail!(error: "Maximum attempts reached. Please request a new OTP.")
      else
        context.fail!(error: "Invalid OTP code")
      end
    end

    otp.consume!

    session = user.sessions.create!(device_info: context.device_info)
    access_token = JwtService.encode_access_token({ user_id: user.id })

    context.user = user
    context.access_token = access_token
    context.refresh_token = session.refresh_token
  end
end
