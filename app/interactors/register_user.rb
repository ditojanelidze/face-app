class RegisterUser
  include Interactor

  def call
    first_name = context.first_name
    last_name = context.last_name
    phone_number = context.phone_number
    normalized_phone = OtpCode.normalize_phone(phone_number)

    if User.exists?(phone_number: normalized_phone, phone_verified: true)
      context.fail!(error: "An account already exists with this phone number")
    end

    # Remove any incomplete (unverified) registration to allow re-registration
    User.where(phone_number: normalized_phone, phone_verified: false).destroy_all

    user = User.new(
      first_name: first_name,
      last_name: last_name,
      phone_number: normalized_phone,
      phone_verified: false
    )

    unless user.save
      context.fail!(error: user.errors.full_messages.join(", "))
    end

    otp = OtpCode.generate_for(normalized_phone)
    SmsService.send_otp(normalized_phone, otp.code)

    context.user = user
  rescue SmsService::SmsDeliveryError => e
    user&.destroy
    context.fail!(error: "Failed to send OTP: #{e.message}")
  end
end
