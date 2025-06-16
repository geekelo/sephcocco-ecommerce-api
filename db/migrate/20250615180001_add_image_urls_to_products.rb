class AddImageUrlsToProducts < ActiveRecord::Migration[7.2]
  def up
    # Add columns to pharmacy products
    add_column :sephcocco_pharmacy_products, :main_image_url, :string
    add_column :sephcocco_pharmacy_products, :other_image_urls, :string, array: true, default: []

    # Add columns to restaurant products
    add_column :sephcocco_restaurant_products, :main_image_url, :string
    add_column :sephcocco_restaurant_products, :other_image_urls, :string, array: true, default: []

    # Add columns to lounge products
    add_column :sephcocco_lounge_products, :main_image_url, :string
    add_column :sephcocco_lounge_products, :other_image_urls, :string, array: true, default: []
  end

  def down
    # Remove columns from pharmacy products
    remove_column :sephcocco_pharmacy_products, :main_image_url, :string
    remove_column :sephcocco_pharmacy_products, :other_image_urls, :string, array: true

    # Remove columns from restaurant products
    remove_column :sephcocco_restaurant_products, :main_image_url, :string
    remove_column :sephcocco_restaurant_products, :other_image_urls, :string, array: true

    # Remove columns from lounge products
    remove_column :sephcocco_lounge_products, :main_image_url, :string
    remove_column :sephcocco_lounge_products, :other_image_urls, :string, array: true
  end
end 