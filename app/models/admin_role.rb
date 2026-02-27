class AdminRole < ApplicationRecord
  ROLES = %w[admin entrance_manager].freeze

  belongs_to :user
  belongs_to :venue

  validates :role, presence: true, inclusion: { in: ROLES }
end