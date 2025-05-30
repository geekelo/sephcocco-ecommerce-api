require_relative '../../lib/migration_helpers/product_likes_migration_helper'

class CreateSephcoccoRestaurantProductLikes < ActiveRecord::Migration[7.2]
  include MigrationHelpers::ProductLikesMigrationHelper

  def up
    create_product_likes_table(
      prefix: 'sephcocco_restaurant',
      user_table: 'sephcocco_users',
      product_table: 'sephcocco_restaurant_products'
    )
  end

  def down
    drop_product_likes_table(
      prefix: 'sephcocco_restaurant',
      user_table: 'sephcocco_users',
      product_table: 'sephcocco_restaurant_products'
    )
  end
end
