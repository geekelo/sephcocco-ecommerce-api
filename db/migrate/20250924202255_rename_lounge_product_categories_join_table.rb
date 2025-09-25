class RenameLoungeProductCategoriesJoinTable < ActiveRecord::Migration[7.2]
  def up
    # Rename the table from the actual database name to what the model expects
    rename_table :sephcocco_lounge_product_categories_sephcocco_lounge_products, 
                 :lounge_product_categories_lounge_products
  end

  def down
    # Reverse the rename
    rename_table :lounge_product_categories_lounge_products,
                 :sephcocco_lounge_product_categories_sephcocco_lounge_products
  end
end
