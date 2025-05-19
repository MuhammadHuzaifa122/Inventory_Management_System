class ChangeRoleToNotNullInUsers < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :role, 0
    User.where(role: nil).update_all(role: 0)  # assign default role to existing NULL roles
    change_column_null :users, :role, false
  end

  def down
    change_column_null :users, :role, true
    change_column_default :users, :role, nil
  end
end
