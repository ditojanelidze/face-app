class OtpCode < ApplicationRecord
  # Validations
  validates :phone_number, presence: true
  validates :code, presence: true
  validates :expires_at, presence: true

  # Callbacks
  before_validation :generate_code, on: :create
  before_validation :set_expiration, on: :create

  # Constants
  OTP_VALIDITY = 5.minutes
  MAX_ATTEMPTS = 5
  CODE_LENGTH = 6

  # Scopes
  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :for_phone, ->(phone) { where(phone_number: normalize_phone(phone)) }

  def self.normalize_phone(phone)
    phone.to_s.gsub(/[\s\-()]/, "")
  end

  def self.generate_for(phone_number)
    normalized_phone = normalize_phone(phone_number)

    # Invalidate any existing OTPs for this phone
    for_phone(normalized_phone).destroy_all

    # Create new OTP
    create!(phone_number: normalized_phone)
  end

  def valid_code?(submitted_code)
    return false if expired?
    return false if max_attempts_reached?

    if code == submitted_code
      true
    else
      increment!(:attempts)
      false
    end
  end

  def expired?
    expires_at <= Time.current
  end

  def max_attempts_reached?
    attempts >= MAX_ATTEMPTS
  end

  def consume!
    destroy!
  end

  private

  def generate_code
    self.code ||= SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")
  end

  def set_expiration
    self.expires_at ||= OTP_VALIDITY.from_now
  end
end
