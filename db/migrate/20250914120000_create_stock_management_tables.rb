require_relative '../../lib/migration_helpers/stock_management_migration_helper'

class CreateStockManagementTables < ActiveRecord::Migration[7.2]
  include MigrationHelpers::StockManagementMigrationHelper

  def up
    # Create stock management tables for all three outlets
    create_stock_management_table(prefix: 'lounge')
    create_stock_management_table(prefix: 'pharmacy')
    create_stock_management_table(prefix: 'restaurant')
  end

  def down
    # Drop stock management tables for all three outlets
    drop_stock_management_table(prefix: 'lounge')
    drop_stock_management_table(prefix: 'pharmacy')
    drop_stock_management_table(prefix: 'restaurant')
  end
end
