class AddBarcodeToProducts < ActiveRecord::Migration[7.2]
  def up
    # Add barcode column to pharmacy products
    add_column :sephcocco_pharmacy_products, :barcode, :string
    add_index :sephcocco_pharmacy_products, :barcode, unique: true

    # Add barcode column to restaurant products
    add_column :sephcocco_restaurant_products, :barcode, :string
    add_index :sephcocco_restaurant_products, :barcode, unique: true

    # Add barcode column to lounge products
    add_column :sephcocco_lounge_products, :barcode, :string
    add_index :sephcocco_lounge_products, :barcode, unique: true
  end

  def down
    # Remove barcode column from pharmacy products
    remove_index :sephcocco_pharmacy_products, :barcode
    remove_column :sephcocco_pharmacy_products, :barcode

    # Remove barcode column from restaurant products
    remove_index :sephcocco_restaurant_products, :barcode
    remove_column :sephcocco_restaurant_products, :barcode

    # Remove barcode column from lounge products
    remove_index :sephcocco_lounge_products, :barcode
    remove_column :sephcocco_lounge_products, :barcode
  end
end
