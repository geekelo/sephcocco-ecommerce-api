# lib/migration_helpers/product_categories_migration_helpers.rb

module MigrationHelpers
  module ProductCategoriesMigrationHelpers
    def create_product_category_table_for(service)
      table_name = "sephcocco_#{service}_product_categories".to_sym

      return if table_exists?(table_name)

      create_table table_name, id: :uuid do |t|
        t.string :name, null: false
        t.string :description
        t.string :slug, null: false

        t.timestamps
      end

      add_index table_name, :name, unique: true
      add_index table_name, :slug, unique: true
    end

    def drop_product_category_table_for(service)
      table_name = "sephcocco_#{service}_product_categories".to_sym

      remove_index table_name, :name
      remove_index table_name, :slug
      drop_table table_name
    end
  end
end
