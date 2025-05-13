class CreateInventoryLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_logs do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.string :operation

      t.timestamps
    end
  end
end
