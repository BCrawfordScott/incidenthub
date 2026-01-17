class MembershipPolicy < ApplicationPolicy
  def index?
    authenticated? && membership.present? && owner_or_admin?
  end

  def show?
    authenticated && membership.present? && (owner_or_admin? || user.id = record.user_id) && same_tenant?
  end

  def create?
    authenticated? && membership.present? && owner_or_admin?
  end

  def update?
    authenticated? && membership.present? && owner_or_admin? && same_tenant?
  end

  def destroy?
    authenticated? && membership.present? && owner_or_admin? && same_tenant?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user.present? && organization.present?
      return scope.none unless Membership.exists?(user_id: user.id, organization_id: organization.id)

      scope.where(organization_id: organization.id)
    end
  end
end
