class CheckoutController < ApplicationController
  def create
    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "usd",
          unit_amount: 500,
          product_data: {
            name: "Product Creation Fee"
          }
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: "#{root_url}payment/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{root_url}products/new"
    )

    redirect_to session.url, allow_other_host: true
  end
end
