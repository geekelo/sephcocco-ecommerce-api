# lib/migration_helpers/product_category_joins_helper.rb

module MigrationHelpers
  module ProductCategoryJoinsHelper
    def create_product_category_join_table(prefix:, product_table:, category_table:)
      join_table = "#{category_table}_#{product_table}"

      create_table join_table.to_sym, id: false do |t|
        t.uuid "#{product_table.singularize}_id".to_sym, null: false
        t.uuid "#{category_table.singularize}_id".to_sym, null: false
      end

      add_index join_table.to_sym,
                [ "#{product_table.singularize}_id".to_sym, "#{category_table.singularize}_id".to_sym ],
                unique: true,
                name: "index_#{product_table}_categories_on_product_and_category"
    end

    def drop_product_category_join_table(prefix:, product_table:, category_table:)
      join_table = "#{category_table}_#{product_table}"

      remove_index join_table.to_sym, name: "index_#{product_table}_categories_on_product_and_category"
      drop_table join_table.to_sym
    end
  end
end
