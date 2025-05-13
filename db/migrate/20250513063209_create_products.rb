class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.text :description
      t.string :category
      t.decimal :price
      t.integer :stock

      t.timestamps
    end
  end
end
