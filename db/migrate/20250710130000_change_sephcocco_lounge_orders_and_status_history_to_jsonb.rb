class ChangeSephcoccoLoungeOrdersAndStatusHistoryToJsonb < ActiveRecord::Migration[7.1]
  include MigrationHelpers::PaymentsMigrationHelper

  def up
    # Change orders and status_history to JSONB for all three outlets
    change_orders_and_status_history_to_jsonb(prefix: 'sephcocco_lounge')
  end

  def down
    # Revert back to string arrays
    change_column :sephcocco_lounge_payments, :orders, :string, array: true, default: [], using: 'orders::text[]'
    change_column :sephcocco_lounge_payments, :status_history, :string, array: true, default: [], using: 'status_history::text[]'
  end
end 