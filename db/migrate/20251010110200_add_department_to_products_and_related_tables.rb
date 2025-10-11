class AddDepartmentToProductsAndRelatedTables < ActiveRecord::Migration[7.2]
  def up
    # Add department to lounge tables
    add_reference :sephcocco_lounge_products, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_lounge_orders, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_lounge_stock_managements, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_lounge_payments, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_lounge_shippings, :sephcocco_lounge_department, type: :uuid, foreign_key: true

    # Add department to pharmacy tables
    add_reference :sephcocco_pharmacy_products, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_pharmacy_orders, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_pharmacy_payments, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_pharmacy_shippings, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true

    # Add department to restaurant tables
    add_reference :sephcocco_restaurant_products, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_restaurant_orders, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_restaurant_payments, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    add_reference :sephcocco_restaurant_shippings, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
  end

  def down
    # Remove department from lounge tables
    remove_reference :sephcocco_lounge_products, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_lounge_orders, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_lounge_stock_managements, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_lounge_payments, :sephcocco_lounge_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_lounge_shippings, :sephcocco_lounge_department, type: :uuid, foreign_key: true

    # Remove department from pharmacy tables
    remove_reference :sephcocco_pharmacy_products, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_pharmacy_orders, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_pharmacy_payments, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_pharmacy_shippings, :sephcocco_pharmacy_department, type: :uuid, foreign_key: true

    # Remove department from restaurant tables
    remove_reference :sephcocco_restaurant_products, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_restaurant_orders, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_restaurant_payments, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
    remove_reference :sephcocco_restaurant_shippings, :sephcocco_restaurant_department, type: :uuid, foreign_key: true
  end
end
