class User < ApplicationRecord
  # Active Storage attachments
  has_one_attached :profile_photo
  has_one_attached :id_card_image

  # Associations
  has_many :sessions, dependent: :destroy
  has_many :approvals, dependent: :destroy
  has_many :venues, dependent: :destroy
  has_many :admin_roles, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-()]+\z/, message: "must be a valid phone number" }

  # Callbacks
  before_save :normalize_phone_number

  def active?
    phone_verified?
  end

  def venue_admin?
    role == "venue_admin" || admin_roles.exists?
  end

  def profile_complete?
    profile_photo.attached? && id_card_image.attached?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def facebook_url
    social_links&.dig("facebook")
  end

  def instagram_url
    social_links&.dig("instagram")
  end

  def linkedin_url
    social_links&.dig("linkedin")
  end

  def facebook_url=(url)
    self.social_links = (social_links || {}).merge("facebook" => url)
  end

  def instagram_url=(url)
    self.social_links = (social_links || {}).merge("instagram" => url)
  end

  def linkedin_url=(url)
    self.social_links = (social_links || {}).merge("linkedin" => url)
  end

  private

  def normalize_phone_number
    self.phone_number = phone_number.gsub(/[\s\-()]/, "") if phone_number.present?
  end
end
