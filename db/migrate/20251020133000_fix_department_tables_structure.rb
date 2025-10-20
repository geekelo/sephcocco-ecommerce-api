class FixDepartmentTablesStructure < ActiveRecord::Migration[7.2]
  def up
    # Fix all three outlet department tables
    %w[lounge pharmacy restaurant].each do |outlet|
      table_name = "sephcocco_#{outlet}_departments"
      
      # Remove foreign key columns that shouldn't exist
      # Departments should NOT have references to products, orders, etc.
      [
        "sephcocco_#{outlet}_product_id",
        "sephcocco_#{outlet}_order_id",
        "sephcocco_#{outlet}_stock_management_id",
        "sephcocco_#{outlet}_payment_id"
      ].each do |column|
        if column_exists?(table_name.to_sym, column.to_sym)
          # Remove foreign key first if it exists
          begin
            remove_foreign_key table_name.to_sym, column: column.to_sym
          rescue => e
            Rails.logger.info "No foreign key to remove for #{column}: #{e.message}"
          end
          
          # Then remove the column
          remove_column table_name.to_sym, column.to_sym
        end
      end
      
      # Add description column if it doesn't exist
      unless column_exists?(table_name.to_sym, :description)
        add_column table_name.to_sym, :description, :text
      end
      
      # Remove address column if it exists (not used)
      if column_exists?(table_name.to_sym, :address)
        remove_column table_name.to_sym, :address
      end
    end
  end

  def down
    # Revert changes - add back columns
    %w[lounge pharmacy restaurant].each do |outlet|
      table_name = "sephcocco_#{outlet}_departments"
      
      # Add back address
      unless column_exists?(table_name.to_sym, :address)
        add_column table_name.to_sym, :address, :text
      end
      
      # Remove description
      if column_exists?(table_name.to_sym, :description)
        remove_column table_name.to_sym, :description
      end
    end
  end
end

