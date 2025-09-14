module MigrationHelpers
  module StockManagementMigrationHelper
    def create_stock_management_table(prefix:)
      create_table "sephcocco_#{prefix}_stock_managements", id: :uuid do |t|
        t.references "sephcocco_#{prefix}_product", null: false, foreign_key: true, type: :uuid
        t.string :invoice_number, null: false
        t.jsonb :stock, default: {}
        t.jsonb :price, default: {}
        t.string :vendor, null: false
        t.string :status, null: false, default: "pending" # pending, approved, cancelled, queried
        t.timestamps
      end
      
      add_index "sephcocco_#{prefix}_stock_managements", :invoice_number
      add_index "sephcocco_#{prefix}_stock_managements", :vendor
      add_index "sephcocco_#{prefix}_stock_managements", :status
      add_index "sephcocco_#{prefix}_stock_managements", :created_at
    end

    def drop_stock_management_table(prefix:)
      drop_table "sephcocco_#{prefix}_stock_managements"
    end
  end
end
