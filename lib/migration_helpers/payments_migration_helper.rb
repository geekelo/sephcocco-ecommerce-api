module MigrationHelpers
  module PaymentsMigrationHelper
    def create_payments_table(prefix:, user_table:, order_table:)
      create_table "#{prefix}_payments" do |t|
        t.string :status, null: false, default: 'pending'
        t.string :status_history, array: true, default: []
        t.decimal :amount, precision: 10, scale: 2
        t.string :payment_method
        t.string :transaction_id
        t.string :orders, array: true, default: []
  
        t.references :#{user_table.singularize}, null: false, foreign_key: { to_table: user_table }
  
        t.timestamps
      end
    end
  
    def drop_payments_table(prefix:)
      drop_table "#{prefix}_payments"
    end
  end
end
