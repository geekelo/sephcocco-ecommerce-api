# lib/migration_helpers/product_likes_migration_helper.rb

module MigrationHelpers
  module ProductLikesMigrationHelper
    def create_product_likes_table(prefix:, user_table:, product_table:)
      table_name = "#{prefix}_product_likes"

      create_table table_name.to_sym, id: :uuid do |t|
        t.uuid :sephcocco_user_id, null: false
        t.uuid "#{prefix}_product_id".to_sym, null: false

        t.timestamps
      end

      add_index table_name.to_sym,
                [ :sephcocco_user_id, "#{prefix}_product_id".to_sym ],
                unique: true,
                name: "index_#{prefix}_product_likes_on_user_and_product"

      add_foreign_key table_name.to_sym, user_table.to_sym, column: :sephcocco_user_id
      add_foreign_key table_name.to_sym, product_table.to_sym, column: "#{prefix}_product_id".to_sym
    end

    def drop_product_likes_table(prefix:, user_table:, product_table:)
      table_name = "#{prefix}_product_likes"

      remove_foreign_key table_name.to_sym, column: :sephcocco_user_id
      remove_foreign_key table_name.to_sym, column: "#{prefix}_product_id".to_sym

      remove_index table_name.to_sym,
                   name: "index_#{prefix}_product_likes_on_user_and_product"

      drop_table table_name.to_sym
    end
  end
end
