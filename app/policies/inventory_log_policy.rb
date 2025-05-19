class InventoryLogPolicy < ApplicationPolicy
  def index?
    user.admin? || user.staff?
  end

  def new?
    user.admin? || user.staff?
  end

  def create?
    user.admin? || user.staff?
  end
end
