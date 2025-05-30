require_relative '../../lib/migration_helpers/product_category_joins_helper'

class CreateJoinTablePharmacyProductsCategories < ActiveRecord::Migration[7.2]
 include MigrationHelpers::ProductCategoryJoinsHelper

  def up
    create_product_category_join_table(
      prefix: 'sephcocco_pharmacy',
      product_table: 'pharmacy_products',
      category_table: 'pharmacy_product_categories'
    )
  end

  def down
    drop_product_category_join_table(
      prefix: 'sephcocco_pharmacy',
      product_table: 'pharmacy_products',
      category_table: 'pharmacy_product_categories'
    )
  end
end
