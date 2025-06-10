class FixJoinTableColumnNames < ActiveRecord::Migration[7.2]
  def change
    rename_column :restaurant_product_categories_restaurant_products,
                  :restaurant_products_id,
                  :restaurant_product_id

    rename_column :restaurant_product_categories_restaurant_products,
                  :restaurant_product_categories_id,
                  :restaurant_product_category_id
  end
end
