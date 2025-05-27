class AddPaidForProductToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :paid_for_product, :boolean, default: false
  end
end
