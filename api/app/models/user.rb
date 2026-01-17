class User < ApplicationRecord
  has_secure_password

  STATUSES = { active: 0, disabled: 1 }.freeze

  enum :status, User::STATUSES, default: :active

  before_validation :normalize_email
  validates :email,
    length: { maximum: 255 },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    presence: true,
    uniqueness: { case_sensitive: false }

  scope :active_users, -> { where(deleted_at: nil, status: :active) }

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  def soft_delete!
    update!(deleted_at: Time.current, status: :disabled)
  end

  def deleted?
    deleted_at.present?
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip.presence
  end
end
