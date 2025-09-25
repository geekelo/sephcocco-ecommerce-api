# db/migrate/20250925103332_rename_lounge_product_categories_join_table.rb
class RenameLoungeProductCategoriesJoinTable < ActiveRecord::Migration[7.2]
  def up
    rename_table :sephcocco_lounge_product_categories_lounge_products, 
                 :lounge_product_categories_lounge_products
  end

  def down
    rename_table :lounge_product_categories_lounge_products,
                 :sephcocco_lounge_product_categories_lounge_products
  end
end