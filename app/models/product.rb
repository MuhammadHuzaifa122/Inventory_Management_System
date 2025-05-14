class Product < ApplicationRecord
  has_many :inventory_logs, dependent: :destroy
  belongs_to :category

  validates :category_id, presence: true
  validates :name, :sku, :price, :stock, presence: true
  validates :sku, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  default_scope { where(deleted_at: nil) }

  scope :only_deleted, -> { where.not(deleted_at: nil) }

  scope :active, -> { where(deleted_at: nil) }

    after_create :log_initial_stock

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end


  def deleted?
    deleted_at.present?
  end
    def log_initial_stock
    return if stock.zero?

    inventory_logs.create!(
      quantity: stock,
      operation: "stock_in"
    )
    end
end
