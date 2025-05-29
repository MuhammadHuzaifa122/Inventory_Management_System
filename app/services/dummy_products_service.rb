require "faraday"
require_relative "../../lib/api_config"  # make sure to require the lib file if not autoloaded

class DummyProductsService
  API_URL = ApiConfig::DUMMY_PRODUCTS_API_URL

  def self.fetch_products
    response = Faraday.get(API_URL)

    if response.success?
      data = JSON.parse(response.body)
      products = data["products"]

      products.map do |product|
        {
          name: product["title"],
          sku: product["id"].to_s,
          description: product["description"],
          category: product["category"],
          price: product["price"],
          stock: product["stock"]
        }
      end
    else
      []
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error("Connection failed: #{e.message}")
    []
  rescue JSON::ParserError => e
    Rails.logger.error("JSON parsing failed: #{e.message}")
    []
  end
end
