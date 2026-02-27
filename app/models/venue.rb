class Venue < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :events, dependent: :destroy
  has_many :approvals, dependent: :destroy

  # Validations
  validates :name, presence: true

  # Scopes
  scope :with_upcoming_events, -> { joins(:events).where("events.date_time > ?", Time.current).distinct }
end
