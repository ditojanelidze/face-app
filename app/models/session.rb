class Session < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :refresh_token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Callbacks
  before_validation :generate_refresh_token, on: :create
  before_validation :set_expiration, on: :create

  # Scopes
  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  REFRESH_TOKEN_VALIDITY = 30.days

  def active?
    expires_at > Time.current
  end

  def expired?
    expires_at <= Time.current
  end

  def refresh!
    update!(
      refresh_token: SecureRandom.hex(32),
      expires_at: REFRESH_TOKEN_VALIDITY.from_now
    )
  end

  private

  def generate_refresh_token
    self.refresh_token ||= SecureRandom.hex(32)
  end

  def set_expiration
    self.expires_at ||= REFRESH_TOKEN_VALIDITY.from_now
  end
end
