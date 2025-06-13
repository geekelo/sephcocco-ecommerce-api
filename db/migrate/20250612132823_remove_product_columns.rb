class RemoveProductColumns < ActiveRecord::Migration[7.2]
    def change
      remove_column :sephcocco_pharmacy_products, :image_url, :string, if_exists: true
      remove_column :sephcocco_pharmacy_products, :other_images, :string, array: true, if_exists: true
      remove_column :sephcocco_lounge_products, :image_url, :string, if_exists: true
      remove_column :sephcocco_lounge_products, :other_images, :string, array: true, if_exists: true
      remove_column :sephcocco_restaurant_products, :image_url, :string, if_exists: true
      remove_column :sephcocco_restaurant_products, :other_images, :string, array: true, if_exists: true
      # Add more remove_column lines for other unwanted fields...
    end
  end
  