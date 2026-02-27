class SendLoginOtp
  include Interactor

  def call
    normalized_phone = OtpCode.normalize_phone(context.phone_number)

    unless User.exists?(phone_number: normalized_phone, phone_verified: true)
      context.fail!(error: "No account found with this phone number. Please register first.")
    end

    otp = OtpCode.generate_for(normalized_phone)
    SmsService.send_otp(normalized_phone, otp.code)
  rescue SmsService::SmsDeliveryError => e
    context.fail!(error: e.message)
  end
end
