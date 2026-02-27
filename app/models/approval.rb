class Approval < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :venue
  belongs_to :event, optional: true

  # Enums
  enum :approval_type, { global: 0, event_specific: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  # Validations
  validates :approval_type, presence: true
  validates :status, presence: true
  validates :event, presence: true, if: :event_specific?
  validate :event_belongs_to_venue, if: -> { event.present? }

  # Callbacks
  before_create :generate_qr_code_data
  after_save :generate_qr_code, if: :saved_change_to_status?

  # Scopes
  scope :active, -> { approved.where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :for_venue, ->(venue_id) { where(venue_id: venue_id) }
  scope :global_approvals, -> { where(approval_type: :global) }
  scope :event_approvals, -> { where(approval_type: :event_specific) }

  def active?
    approved? && (expires_at.nil? || expires_at > Time.current) && !qr_used?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def qr_code_svg
    return nil unless qr_code_data.present?

    qrcode = RQRCode::QRCode.new(qr_code_data)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    )
  end

  def qr_code_png
    return nil unless qr_code_data.present?

    qrcode = RQRCode::QRCode.new(qr_code_data)
    qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false
    )
  end

  def mark_as_used!
    update!(qr_used: true)
  end

  private

  def generate_qr_code_data
    self.qr_code_data = SecureRandom.uuid
  end

  def generate_qr_code
    # QR code data is already set, nothing additional needed
  end

  def event_belongs_to_venue
    return unless event.present? && venue.present?
    errors.add(:event, "must belong to the selected venue") unless event.venue_id == venue_id
  end
end
