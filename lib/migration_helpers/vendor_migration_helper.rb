module MigrationHelpers
  module VendorMigrationHelper
    def create_vendor_table(prefix:)
      create_table "sephcocco_#{prefix}_vendors", id: :uuid do |t|
        t.string :name, null: false
        t.string :email, null: false
        t.string :phone, null: false
        t.string :address, null: false
        t.string :city, null: false
        t.string :state, null: false
        t.string :bank_details, null: false
        t.string :country, null: false
        t.timestamps
      end
    end

    def add_index_to_vendor_table(prefix:)
      add_index "sephcocco_#{prefix}_vendors", :name, unique: true
      add_index "sephcocco_#{prefix}_vendors", :email, unique: true
      add_index "sephcocco_#{prefix}_vendors", :phone, unique: true
      add_index "sephcocco_#{prefix}_vendors", :address, unique: true
    end

    def remove_index_from_vendor_table(prefix:)
      remove_index "sephcocco_#{prefix}_vendors", :name
      remove_index "sephcocco_#{prefix}_vendors", :email
      remove_index "sephcocco_#{prefix}_vendors", :phone
      remove_index "sephcocco_#{prefix}_vendors", :address
    end
    
    def drop_vendor_table(prefix:)
      drop_table "sephcocco_#{prefix}_vendors"
    end
  end
end
