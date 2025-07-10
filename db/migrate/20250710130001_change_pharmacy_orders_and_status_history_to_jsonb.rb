class ChangePharmacyOrdersAndStatusHistoryToJsonb < ActiveRecord::Migration[7.1]
  include MigrationHelpers::PaymentsMigrationHelper

  def up
    change_orders_and_status_history_to_jsonb(prefix: 'sephcocco_pharmacy')
  end

  def down
    change_column :sephcocco_pharmacy_payments, :orders, :string, array: true, default: [], using: 'orders::text[]'
    change_column :sephcocco_pharmacy_payments, :status_history, :string, array: true, default: [], using: 'status_history::text[]'
  end
end 