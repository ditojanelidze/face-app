class SmsService
  class << self
    def send_otp(phone_number, code)
      message = "Your verification code is: #{code}. It expires in 5 minutes."

      if twilio_configured?
        send_via_twilio(phone_number, message)
      else
        # Development/test fallback - log the OTP
        log_otp(phone_number, code)
      end
    end

    private

    def twilio_configured?
      twilio_account_sid.present? && twilio_auth_token.present? && twilio_phone_number.present?
    end

    def send_via_twilio(to, message)
      client = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token)

      client.messages.create(
        from: twilio_phone_number,
        to: to,
        body: message
      )

      Rails.logger.info("SMS sent to #{to}")
      true
    rescue Twilio::REST::RestError => e
      Rails.logger.error("Failed to send SMS to #{to}: #{e.message}")
      raise SmsDeliveryError, "Failed to send SMS: #{e.message}"
    end

    def log_otp(phone_number, code)
      Rails.logger.info("=" * 50)
      Rails.logger.info("OTP CODE FOR #{phone_number}: #{code}")
      Rails.logger.info("=" * 50)

      # Also output to console in development
      if Rails.env.development?
        puts "\n#{"=" * 50}"
        puts "OTP CODE FOR #{phone_number}: #{code}"
        puts "#{"=" * 50}\n"
      end

      true
    end

    def twilio_account_sid
      Rails.application.credentials.dig(:twilio, :account_sid) || ENV["TWILIO_ACCOUNT_SID"]
    end

    def twilio_auth_token
      Rails.application.credentials.dig(:twilio, :auth_token) || ENV["TWILIO_AUTH_TOKEN"]
    end

    def twilio_phone_number
      Rails.application.credentials.dig(:twilio, :phone_number) || ENV["TWILIO_PHONE_NUMBER"]
    end
  end

  class SmsDeliveryError < StandardError; end
end
