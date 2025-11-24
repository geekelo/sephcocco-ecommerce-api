require_relative '../../lib/migration_helpers/vendor_migration_helper'

class CreateSephcoccoVendors < ActiveRecord::Migration[7.2]
  include MigrationHelpers::VendorMigrationHelper

  def up
    # Create vendor tables for all three outlets
    create_vendor_table(prefix: 'lounge')
    create_vendor_table(prefix: 'pharmacy')
    create_vendor_table(prefix: 'restaurant')
  end

  def down
    # Drop vendor tables for all three outlets
    drop_vendor_table(prefix: 'lounge')
    drop_vendor_table(prefix: 'pharmacy')
    drop_vendor_table(prefix: 'restaurant')
  end
end
