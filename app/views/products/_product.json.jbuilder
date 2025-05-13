json.extract! product, :id, :name, :sku, :description, :category, :price, :stock, :created_at, :updated_at
json.url product_url(product, format: :json)
