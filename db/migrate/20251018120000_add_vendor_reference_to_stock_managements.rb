class AddVendorReferenceToStockManagements < ActiveRecord::Migration[7.2]
  def up
    # Lounge
    if column_exists?(:sephcocco_lounge_stock_managements, :vendor)
      remove_column :sephcocco_lounge_stock_managements, :vendor
    end
    
    unless column_exists?(:sephcocco_lounge_stock_managements, :sephcocco_lounge_vendor_id)
      add_reference :sephcocco_lounge_stock_managements, :sephcocco_lounge_vendor, type: :uuid, foreign_key: { to_table: :sephcocco_lounge_vendors }, null: true
    end
    
    unless column_exists?(:sephcocco_lounge_stock_managements, :sephcocco_lounge_department_id)
      add_column :sephcocco_lounge_stock_managements, :sephcocco_lounge_department_id, :uuid
    end
    
    unless foreign_key_exists?(:sephcocco_lounge_stock_managements, :sephcocco_lounge_departments, column: :sephcocco_lounge_department_id)
      add_foreign_key :sephcocco_lounge_stock_managements, :sephcocco_lounge_departments, column: :sephcocco_lounge_department_id
    end

    # Pharmacy
    if column_exists?(:sephcocco_pharmacy_stock_managements, :vendor)
      remove_column :sephcocco_pharmacy_stock_managements, :vendor
    end
    
    unless column_exists?(:sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_vendor_id)
      add_reference :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_vendor, type: :uuid, foreign_key: { to_table: :sephcocco_pharmacy_vendors }, null: true
    end
    
    unless column_exists?(:sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_department_id)
      add_column :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_department_id, :uuid
    end
    
    unless foreign_key_exists?(:sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_departments, column: :sephcocco_pharmacy_department_id)
      add_foreign_key :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_departments, column: :sephcocco_pharmacy_department_id
    end

    # Restaurant
    if column_exists?(:sephcocco_restaurant_stock_managements, :vendor)
      remove_column :sephcocco_restaurant_stock_managements, :vendor
    end
    
    unless column_exists?(:sephcocco_restaurant_stock_managements, :sephcocco_restaurant_vendor_id)
      add_reference :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_vendor, type: :uuid, foreign_key: { to_table: :sephcocco_restaurant_vendors }, null: true
    end
    
    unless column_exists?(:sephcocco_restaurant_stock_managements, :sephcocco_restaurant_department_id)
      add_column :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_department_id, :uuid
    end
    
    unless foreign_key_exists?(:sephcocco_restaurant_stock_managements, :sephcocco_restaurant_departments, column: :sephcocco_restaurant_department_id)
      add_foreign_key :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_departments, column: :sephcocco_restaurant_department_id
    end
  end

  def down
    # Lounge
    if column_exists?(:sephcocco_lounge_stock_managements, :sephcocco_lounge_vendor_id)
      remove_reference :sephcocco_lounge_stock_managements, :sephcocco_lounge_vendor
    end
    
    unless column_exists?(:sephcocco_lounge_stock_managements, :vendor)
      add_column :sephcocco_lounge_stock_managements, :vendor, :string
    end

    # Pharmacy
    if column_exists?(:sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_vendor_id)
      remove_reference :sephcocco_pharmacy_stock_managements, :sephcocco_pharmacy_vendor
    end
    
    unless column_exists?(:sephcocco_pharmacy_stock_managements, :vendor)
      add_column :sephcocco_pharmacy_stock_managements, :vendor, :string
    end

    # Restaurant
    if column_exists?(:sephcocco_restaurant_stock_managements, :sephcocco_restaurant_vendor_id)
      remove_reference :sephcocco_restaurant_stock_managements, :sephcocco_restaurant_vendor
    end
    
    unless column_exists?(:sephcocco_restaurant_stock_managements, :vendor)
      add_column :sephcocco_restaurant_stock_managements, :vendor, :string
    end
  end
end
