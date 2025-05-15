FactoryBot.define do
  factory :product do
    name { "Sample Product" }
    sku { "SKU123" }
    description { "A description of the product" }
    price { 10.0 }
    stock { 100 }
    association :category
  end
end
