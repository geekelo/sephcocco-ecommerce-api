class AddDeliveryLocationToPayments < ActiveRecord::Migration[7.2]
  def up
    # Add delivery_location column to lounge payments
    add_column :sephcocco_lounge_payments, :delivery_location, :jsonb, default: {}

    # Add delivery_location column to pharmacy payments
    add_column :sephcocco_pharmacy_payments, :delivery_location, :jsonb, default: {}

    # Add delivery_location column to restaurant payments
    add_column :sephcocco_restaurant_payments, :delivery_location, :jsonb, default: {}
  end

  def down
    # Remove delivery_location column from lounge payments
    remove_column :sephcocco_lounge_payments, :delivery_location

    # Remove delivery_location column from pharmacy payments
    remove_column :sephcocco_pharmacy_payments, :delivery_location

    # Remove delivery_location column from restaurant payments
    remove_column :sephcocco_restaurant_payments, :delivery_location
  end
end
