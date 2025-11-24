# db/migrate/20250925103332_rename_lounge_product_categories_join_table.rb
class RenameLoungeProductCategoriesJoinTable < ActiveRecord::Migration[7.2]
  def up
    # Only rename if the old table exists (for databases that were created before the rename)
    if table_exists?(:sephcocco_lounge_product_categories_products)
      rename_table :sephcocco_lounge_product_categories_products, 
                   :lounge_product_categories_lounge_products
    end
  end

  def down
    # Only rename back if the new table exists and old one doesn't
    if table_exists?(:lounge_product_categories_lounge_products) && 
       !table_exists?(:sephcocco_lounge_product_categories_products)
      rename_table :lounge_product_categories_lounge_products,
                   :sephcocco_lounge_product_categories_products
    end
  end
end