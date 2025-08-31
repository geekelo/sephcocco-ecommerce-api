class AddPaymentIdToOrders < ActiveRecord::Migration[7.2]
  def change
    # Add payment_id to pharmacy orders
    add_reference :sephcocco_pharmacy_orders, :sephcocco_pharmacy_payment, type: :uuid, null: true, foreign_key: { to_table: :sephcocco_pharmacy_payments }
    
    # Add payment_id to restaurant orders
    add_reference :sephcocco_restaurant_orders, :sephcocco_restaurant_payment, type: :uuid, null: true, foreign_key: { to_table: :sephcocco_restaurant_payments }
    
    # Add payment_id to lounge orders
    add_reference :sephcocco_lounge_orders, :sephcocco_lounge_payment, type: :uuid, null: true, foreign_key: { to_table: :sephcocco_lounge_payments }
  end
end
