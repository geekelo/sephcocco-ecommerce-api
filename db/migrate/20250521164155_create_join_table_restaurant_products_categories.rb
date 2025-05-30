require_relative '../../lib/migration_helpers/product_category_joins_helper'

class CreateJoinTableRestaurantProductsCategories < ActiveRecord::Migration[7.2]
 include MigrationHelpers::ProductCategoryJoinsHelper

  def up
    create_product_category_join_table(
      prefix: 'sephcocco_restaurant',
      product_table: 'restaurant_products',
      category_table: 'restaurant_product_categories'
    )
  end

  def down
    drop_product_category_join_table(
      prefix: 'sephcocco_restaurant',
      product_table: 'restaurant_products',
      category_table: 'restaurant_product_categories'
    )
  end
end
