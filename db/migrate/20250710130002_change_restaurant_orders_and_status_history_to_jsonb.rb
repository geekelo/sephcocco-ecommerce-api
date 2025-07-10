class ChangeRestaurantOrdersAndStatusHistoryToJsonb < ActiveRecord::Migration[7.1]
  include MigrationHelpers::PaymentsMigrationHelper

  def up
    change_orders_and_status_history_to_jsonb(prefix: 'sephcocco_restaurant')
  end

  def down
    change_column :sephcocco_restaurant_payments, :orders, :string, array: true, default: [], using: 'orders::text[]'
    change_column :sephcocco_restaurant_payments, :status_history, :string, array: true, default: [], using: 'status_history::text[]'
  end
end 