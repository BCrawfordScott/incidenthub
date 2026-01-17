class Organization < ApplicationRecord
  STATUSES = { enabled: 0, disabled: 1 }.freeze

  enum :status, Organization::STATUSES, default: :enabled

  validates :name, presence: true
  validates :billing_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
end
