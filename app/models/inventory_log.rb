# app/models/inventory_log.rb
class InventoryLog < ApplicationRecord
  belongs_to :product
  enum :operation, {
    stock_in: "stock_in",
    stock_out: "stock_out"
  }

  validates :operation, presence: true, inclusion: { in: operations.keys }
  validates :product, presence: true
end
