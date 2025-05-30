require_relative '../../lib/migration_helpers/product_categories_migration_helpers'

class CreateSephcoccoRestaurantProductCategories < ActiveRecord::Migration[7.2]
 include MigrationHelpers::ProductCategoriesMigrationHelpers

  def up
    create_product_category_table_for("restaurant")
  end

  def down
    drop_product_category_table_for("restaurant")
  end
end
