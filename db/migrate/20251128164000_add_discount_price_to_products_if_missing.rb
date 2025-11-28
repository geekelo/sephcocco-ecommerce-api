class AddDiscountPriceToProductsIfMissing < ActiveRecord::Migration[7.2]
  def up
    # Add discount_price to pharmacy products if it doesn't exist
    unless column_exists?(:sephcocco_pharmacy_products, :discount_price)
      add_column :sephcocco_pharmacy_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0
    end

    # Add discount_price to restaurant products if it doesn't exist
    unless column_exists?(:sephcocco_restaurant_products, :discount_price)
      add_column :sephcocco_restaurant_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0
    end

    # Add discount_price to lounge products if it doesn't exist
    unless column_exists?(:sephcocco_lounge_products, :discount_price)
      add_column :sephcocco_lounge_products, :discount_price, :decimal, precision: 16, scale: 2, null: false, default: 0.0
    end
  end

  def down
    # Remove discount_price from pharmacy products if it exists
    if column_exists?(:sephcocco_pharmacy_products, :discount_price)
      remove_column :sephcocco_pharmacy_products, :discount_price
    end

    # Remove discount_price from restaurant products if it exists
    if column_exists?(:sephcocco_restaurant_products, :discount_price)
      remove_column :sephcocco_restaurant_products, :discount_price
    end

    # Remove discount_price from lounge products if it exists
    if column_exists?(:sephcocco_lounge_products, :discount_price)
      remove_column :sephcocco_lounge_products, :discount_price
    end
  end
end

