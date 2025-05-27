class PaymentsController < ApplicationController
  def success
    session_id = params[:session_id]
    return redirect_to products_path, alert: "Missing session ID" unless session_id

    stripe_session = Stripe::Checkout::Session.retrieve(session_id)

    if stripe_session.payment_status == "paid"
      # 💾 Store it in Rails session
      session[:product_payment_session_id] = session_id

      redirect_to new_product_path, notice: "Payment successful! You can now add a product."
    else
      redirect_to products_path, alert: "Payment was not successful."
    end
  end
end
