class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV.fetch("JWT_SECRET_KEY", "development_secret_key")
  ALGORITHM = "HS256"
  ACCESS_TOKEN_EXPIRY = 1.hour
  ADMIN_ACCESS_TOKEN_EXPIRY = 8.hours

  class << self
    def encode_access_token(payload, expiry: ACCESS_TOKEN_EXPIRY)
      payload = payload.dup
      payload[:exp] = expiry.from_now.to_i
      payload[:iat] = Time.current.to_i
      payload[:type] = "access"

      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def encode_admin_access_token(payload)
      encode_access_token(payload, expiry: ADMIN_ACCESS_TOKEN_EXPIRY)
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::ExpiredSignature
      raise TokenExpiredError, "Token has expired"
    rescue JWT::DecodeError => e
      raise InvalidTokenError, "Invalid token: #{e.message}"
    end

    def valid?(token)
      decode(token)
      true
    rescue TokenExpiredError, InvalidTokenError
      false
    end
  end

  class TokenExpiredError < StandardError; end
  class InvalidTokenError < StandardError; end
end
