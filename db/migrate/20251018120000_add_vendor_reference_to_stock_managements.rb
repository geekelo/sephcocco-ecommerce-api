class AddVendorReferenceToStockManagements < ActiveRecord::Migration[7.2]
  def up
    # Lounge
    # Remove the old vendor string column and add foreign key reference
    remove_column :sephcocco_lounge_stock_managements, :vendor
    add_reference :sephcocco_lounge_stock_managements, :sephcocco_lounge_vendor, type: :uuid, foreign_key: { to_table: :sephcocco_lounge_vendors }, null: true
    add_column :sephcocco_lounge_stock_managements, :sephcocco_lounge_department_id, :uuid
    add_foreign_key :sephcocco_lounge_stock_managements, :sephcocco_lounge_departments, column: :sephcocco_lounge_department_id

    # Pharmacy
    # Remove the old vendor string column and add foreign key reference
    remove_column :sephcocco_pharmacy_stock_managements, :vendor
    add_reference :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_vendor, type: :uuid, foreign_key: { to_table: :sephcocco_pharmacy_vendors }, null: true
    add_column :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_department_id, :uuid
    add_foreign_key :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_departments, column: :sephcocco_pharmacy_department_id

    # Restaurant
    # Remove the old vendor string column and add foreign key reference
    remove_column :sephcocco_restaurant_stock_managements, :vendor
    add_reference :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_vendor, type: :uuid, foreign_key: { to_table: :sephcocco_restaurant_vendors }, null: true
    add_column :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_department_id, :uuid
    add_foreign_key :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_departments, column: :sephcocco_restaurant_department_id
  end

  def down
    # Lounge
    remove_foreign_key :sephcocco_lounge_stock_managements, column: :sephcocco_lounge_department_id
    remove_column :sephcocco_lounge_stock_managements, :sephcocco_lounge_department_id
    remove_reference :sephcocco_lounge_stock_managements, :sephcocco_lounge_vendor
    add_column :sephcocco_lounge_stock_managements, :vendor, :string, null: false

    # Pharmacy
    remove_foreign_key :sephcocco_pharmacy_stock_managements, column: :sephcocco_pharmacy_department_id
    remove_column :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_department_id
    remove_reference :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_vendor
    add_column :sephcocco_pharmacy_stock_managements, :vendor, :string, null: false

    # Restaurant
    remove_foreign_key :sephcocco_restaurant_stock_managements, column: :sephcocco_restaurant_department_id
    remove_column :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_department_id
    remove_reference :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_vendor
    add_column :sephcocco_restaurant_stock_managements, :vendor, :string, null: false
  end
end

