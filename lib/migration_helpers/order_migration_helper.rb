# lib/migration_helpers/order_migration_helper.rb

module MigrationHelpers
  module OrderMigrationHelper
    def create_orders_table(prefix:, user_table:, product_table:)
      table_name = "#{prefix}_orders".to_sym

      create_table table_name, id: :uuid do |t|
        t.references product_table.singularize.to_sym, type: :uuid, null: false, foreign_key: { to_table: product_table.to_sym }
        t.references :sephcocco_user, type: :uuid, null: false, foreign_key: { to_table: user_table.to_sym }

        t.string :status, null: false, default: "pending"
        t.string :stages, array: true, default: []
        t.string :current_stage, null: false
        t.string :order_number, null: false
        t.integer :quantity, null: false
        t.decimal :unit_price, precision: 10, scale: 2, null: false
        t.decimal :total_price, precision: 10, scale: 2, null: false
        t.decimal :total_cost, precision: 10, scale: 2, null: false
        t.string :address
        
        t.timestamps
      end
    end

    def drop_orders_table(prefix:)
      drop_table "#{prefix}_orders".to_sym
    end
  end
end
