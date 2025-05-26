require "csv"

class Product < ApplicationRecord
  has_many :inventory_logs, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :image
  belongs_to :category
  after_commit :send_email_after_delay, on: :create

  validates :category_id, presence: true
  validates :name, :sku, :price, :stock, presence: true
  validates :sku, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :low_stock, ->(threshold = ENV["LOW_STOCK_THRESHOLD"].to_i) {
    where("stock <= ?", threshold)
  }

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
    def self.import(file)
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1)

      (2..spreadsheet.last_row).each do |i|
        row = Hash [ [ header, spreadsheet.row(i) ].transpose ]
        product = find_by(name: row["name"])

        if product
          stock_in = row["stock_in"].to_i
          stock_out = row["stock_out"].to_i
          product.stock += stock_in - stock_out
          product.save
        end
      end
    end

# for .csv

def self.import_from_csv(file)
  CSV.foreach(file.path, headers: true) do |row|
    row = row.to_h.transform_keys(&:downcase)

    product_name = row["name"]&.strip
    stock_in = row["stock in"].to_i
    stock_out = row["stock out"].to_i

    next if product_name.blank?

    product = Product.where("LOWER(name) = ?", product_name.downcase).first

    if product
      product.stock += stock_in - stock_out
      product.stock = 0 if product.stock.negative?
      product.save!
    else
      Rails.logger.warn "Product not found: #{product_name}"
    end
  end
end
end

private

  def send_email_after_delay
    Thread.new do
      sleep 20 # 1 minute delay
      ProductMailer.product_created_email(self).deliver_now
    end
  end
