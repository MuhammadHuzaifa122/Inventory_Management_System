class ProductPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.admin? || user.staff?
  end

  def update?
    user.admin? || user.staff?
  end

  def destroy?
    user.admin?
  end

  def import?
    user.admin?
  end
end
