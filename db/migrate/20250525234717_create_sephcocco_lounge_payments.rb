require_relative '../../lib/migration_helpers/payments_migration_helper'

class CreateSephcoccoLoungePayments < ActiveRecord::Migration[7.2]
  include MigrationHelpers::PaymentsMigrationHelper

  def up
    create_payments_table(
      prefix: 'sephcocco_lounge',
      user_table: 'sephcocco_users',
      order_table: 'sephcocco_lounge_orders'
    )
  end

  def down
    drop_payments_table(prefix: 'sephcocco_lounge')
  end
end
