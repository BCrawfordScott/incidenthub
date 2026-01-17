class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  ROLES = { owner: 0, admin: 1, member: 2, read_only: 3 }.freeze

  enum :role, Membership::ROLES, default: :member

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :organization_id }
end
