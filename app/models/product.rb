class Product < ApplicationRecord
  belongs_to :category

  validates :category_id, presence: true
  validates :name, :sku, :price, :stock, presence: true
  validates :sku, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # Scope to get only active (not deleted) products
  default_scope { where(deleted_at: nil) }

  # Scope to get deleted products if needed
  scope :only_deleted, -> { where.not(deleted_at: nil) }


  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end
end
