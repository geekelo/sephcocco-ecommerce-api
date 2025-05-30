require_relative '../../lib/migration_helpers/product_likes_migration_helper'

class CreateSephcoccoPharmacyProductLikes < ActiveRecord::Migration[7.2]
  include MigrationHelpers::ProductLikesMigrationHelper

  def up
    create_product_likes_table(
      prefix: 'sephcocco_pharmacy',
      user_table: 'sephcocco_users',
      product_table: 'sephcocco_pharmacy_products'
    )
  end

  def down
    drop_product_likes_table(
      prefix: 'sephcocco_pharmacy',
      user_table: 'sephcocco_users',
      product_table: 'sephcocco_pharmacy_products'
    )
  end
end
