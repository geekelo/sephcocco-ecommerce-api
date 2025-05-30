require_relative '../../lib/migration_helpers/product_migration_helpers'

class CreateSephcoccoPharmacyProducts < ActiveRecord::Migration[7.2]
  include MigrationHelpers::ProductMigrationHelpers

  def up
    create_product_table_for('pharmacy')
  end

  def down
    drop_product_table_for('pharmacy')
  end
end
