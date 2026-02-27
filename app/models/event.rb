class Event < ApplicationRecord
  # Associations
  belongs_to :venue
  has_many :approvals, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :date_time, presence: true

  # Scopes
  scope :upcoming, -> { where("date_time > ?", Time.current).order(:date_time) }
  scope :past, -> { where("date_time <= ?", Time.current).order(date_time: :desc) }

  def upcoming?
    date_time > Time.current
  end

  def past?
    date_time <= Time.current
  end
end
