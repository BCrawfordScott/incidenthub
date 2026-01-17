# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record, :organization

  def initialize(user, record)
    @user = user
    @record = record
    @organization = Current.organization
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope, :organization

    def initialize(user, scope)
      @user = user
      @scope = scope
      @organization = Current.organization
    end

    def resolve
      scope.none
    end

    private

    def authenticated?
      user.present?
    end

    def same_tenant?
      organization.present? &&
        record.respond_to?(:organization_id) &&
        record.organization_id == organization.id
    end

    def membership
      return nil unless authenticated? && organization
      Membership.find_by(user_id: user.id, organization_id: organization.id)
    end

    def role
      membership&.role
    end

    def owner_or_admin?
      %w[owner admin].include?(role)
    end

    def member_or_higher?
      %w[owner admin member].include?(role)
    end
  end
end
