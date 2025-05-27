class RemovePaidForProductFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :paid_for_product, :boolean
  end
end
