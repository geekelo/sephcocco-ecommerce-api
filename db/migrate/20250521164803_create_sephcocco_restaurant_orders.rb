require_relative '../../lib/migration_helpers/order_migration_helper'

class CreateSephcoccoRestaurantOrders < ActiveRecord::Migration[7.2]
  include MigrationHelpers::OrderMigrationHelper

  def up
    create_orders_table(
      prefix: 'sephcocco_restaurant',
      user_table: 'sephcocco_users',
      product_table: 'sephcocco_restaurant_products'
    )
  end

  def down
    drop_orders_table(prefix: 'sephcocco_restaurant')
  end
end
