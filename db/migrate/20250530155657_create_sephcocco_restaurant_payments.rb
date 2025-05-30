require_relative '../../lib/migration_helpers/payments_migration_helper'

class CreateSephcoccoRestaurantPayments < ActiveRecord::Migration[7.2]
  include MigrationHelpers::PaymentsMigrationHelper

  def up
    create_payments_table(
      prefix: 'sephcocco_restaurant',
      user_table: 'sephcocco_users',
      order_table: 'sephcocco_restaurant_orders'
    )
  end

  def down
    drop_payments_table(prefix: 'sephcocco_restaurant')
  end
end
