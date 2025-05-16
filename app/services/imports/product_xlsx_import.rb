require "roo"

module Imports
  class ProductXlsxImport
    def initialize(file)
      @file = file
    end

    def import
      spreadsheet = Roo::Excelx.new(@file.path)
      header = spreadsheet.row(1).map(&:downcase)

      name_idx = header.index("name")
      stock_in_idx = header.index("stock in")
      stock_out_idx = header.index("stock out")

      (2..spreadsheet.last_row).each do |i|
        row = spreadsheet.row(i)
        product_name = row[name_idx]&.strip
        stock_in = row[stock_in_idx].to_i
        stock_out = row[stock_out_idx].to_i

        next if product_name.blank?

        product = Product.where("LOWER(name) = ?", product_name.downcase).first

        if product
          product.stock = [ product.stock.to_i + stock_in - stock_out, 0 ].max
          product.save!
        end
      end
    end
  end
end
