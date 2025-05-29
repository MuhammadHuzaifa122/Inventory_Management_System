# app/controllers/concerns/pagination_helper.rb
module PaginationHelper
  extend ActiveSupport::Concern

  def format_and_paginate_products(db_products:, page:, per_page: 5)
    formatted_db_products = db_products.map do |product|
      {
        name: product.name,
        sku: product.sku,
        description: product.description,
        category: product.category&.name || "No Category",
        price: product.price,
        stock: product.stock,
        source: "db",
        id: product.id
      }
    end

    api_products = DummyProductsService.fetch_products.map do |product|
      product.merge(source: "api")
    end

    combined = formatted_db_products + api_products

    WillPaginate::Collection.create(page || 1, per_page, combined.length) do |pager|
      start = (pager.current_page - 1) * pager.per_page
      pager.replace(combined[start, pager.per_page])
    end
  end
end
