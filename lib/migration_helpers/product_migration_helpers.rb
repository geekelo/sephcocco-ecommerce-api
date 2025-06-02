# lib/migration_helpers/product_migration_helpers.rb

module MigrationHelpers
  module ProductMigrationHelpers
    def create_product_table_for(service)
      table_name = "sephcocco_#{service}_products".to_sym

      create_table table_name, id: :uuid do |t|
        t.string :name, null: false
        t.string :image_url
        t.decimal :price, precision: 16, scale: 2, null: false, default: 0.0
        t.integer :amount_in_stock, null: false, default: 0
        t.string  :short_description
        t.text    :long_description
        t.string  :other_images, array: true, default: []
        t.integer :likes, null: false, default: 0
        t.boolean :visible, null: false, default: false

        t.timestamps
      end

      add_index table_name, :name, unique: true
    end

    def drop_product_table_for(service)
      table_name = "sephcocco_#{service}_products".to_sym

      remove_index table_name, :name
      drop_table table_name
    end
  end
end
