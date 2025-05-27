class AddStripePaymentDataToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stripe_payment_data, :jsonb, null: false, default: {}
  end
end
