require "csv"

module Imports
  class ProductCsvImport
    def initialize(file)
      @file = file
    end

    def import
      CSV.foreach(@file.path, headers: true) do |row|
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
end
