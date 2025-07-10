module MigrationHelpers
  module PaymentsMigrationHelper
    def create_payments_table(prefix:, user_table:, order_table:)
      create_table "#{prefix}_payments", id: :uuid do |t|
        t.string :status, null: false, default: "pending"
        t.string :status_history, array: true, default: []
        t.decimal :amount, precision: 10, scale: 2
        t.string :payment_method
        t.string :transaction_id
        t.string :orders, array: true, default: []

        t.references user_table.singularize.to_sym, null: false, foreign_key: { to_table: user_table }, type: :uuid

        t.timestamps
      end
    end

    def drop_payments_table(prefix:)
      drop_table "#{prefix}_payments"
    end

    def change_orders_and_status_history_to_jsonb(prefix:)
      # First remove the default values
      change_column_default "#{prefix}_payments", :orders, from: [], to: nil
      change_column_default "#{prefix}_payments", :status_history, from: [], to: nil
      
      # Then change the column types
      change_column "#{prefix}_payments", :orders, :jsonb, using: 'to_json(orders)'
      change_column "#{prefix}_payments", :status_history, :jsonb, using: 'to_json(status_history)'
      
      # Finally set the new default values
      change_column_default "#{prefix}_payments", :orders, from: nil, to: []
      change_column_default "#{prefix}_payments", :status_history, from: nil, to: []
    end
  end
end
