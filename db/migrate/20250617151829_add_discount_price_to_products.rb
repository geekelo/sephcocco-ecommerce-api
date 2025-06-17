class AddDiscountPriceToProducts < ActiveRecord::Migration[7.2]
  def up
    # Add columns to pharmacy products
    add_column :sephcocco_pharmacy_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0

    # Add columns to restaurant products
    add_column :sephcocco_restaurant_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0

    # Add columns to lounge products
    add_column :sephcocco_lounge_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0
  end

  def down
    # Remove columns from pharmacy products
    remove_column :sephcocco_pharmacy_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0

    # Remove columns from restaurant products
    remove_column :sephcocco_restaurant_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0

    # Remove columns from lounge products
    remove_column :sephcocco_lounge_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0
  end
end
