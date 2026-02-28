# frozen_string_literal: true

class AuthToken
  ALGORITHM = "HS256"
  TOKEN_EXPIRY = 24.hours

  class << self
    def encode(user)
      payload = {
        sub: user.id,
        exp: TOKEN_EXPIRY.from_now.to_i,
        iat: Time.current.to_i
      }
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
      decoded.first.with_indifferent_access
    rescue JWT::ExpiredSignature
      nil
    rescue JWT::DecodeError
      nil
    end

    private

    def secret_key
      Rails.application.credentials.secret_key_base || ENV.fetch("SECRET_KEY_BASE")
    end
  end
end
