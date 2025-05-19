class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    case user.role
    when "staff"
      can [ :read, :update ], Product
      can :manage, InventoryLog


    when "admin"
      can :manage, Product
      can :manage, InventoryLog
      can :view_reports, :report
      can :import, Product
    else
      cannot :manage, :all
    end
  end
end
