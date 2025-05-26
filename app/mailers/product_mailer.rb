class ProductMailer < ApplicationMailer
  def product_created_email(product)
    @product = product
    mail(to: "your_email@example.com", subject: "New Product Created")
  end
end
