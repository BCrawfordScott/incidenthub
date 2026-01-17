class OrganizationPolicy < ApplicationPolicy
  def show?
    authenticated? && membership.present?
  end

  def update?
    show? && admin_or_owner?
  end

  class Scope < Scope
    def resolve
      return scope.non unless user.present?
      scope.joins(:memberships).where(memberships: { user_id: user.id })
    end
  end
end