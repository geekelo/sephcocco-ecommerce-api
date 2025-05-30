require_relative '../../lib/migration_helpers/order_migration_helper'

class CreateSephcoccoLoungeOrders < ActiveRecord::Migration[7.2]
  include MigrationHelpers::OrderMigrationHelper

  def up
    create_orders_table(
      prefix: 'sephcocco_lounge',
      user_table: 'sephcocco_users',
      product_table: 'sephcocco_lounge_products'
    )
  end

  def down
    drop_orders_table(prefix: 'sephcocco_lounge')
  end
end
