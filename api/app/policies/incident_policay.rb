# frozen_string_literal: true

class IncidentPolicy < ApplicationPolicy
  def index?
    authenticated? && membership.present?
  end

  def show?
    authenticated? && membership.present? && same_tenant?
  end

  def create?
    authenticated? && membership.present? && member_or_higher?
  end

  def update?
    authenticated? && membership.present? && member_or_higher? && same_tenant?
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
