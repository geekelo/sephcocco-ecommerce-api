class RemoveImageColumnsFromProducts < ActiveRecord::Migration[7.2]
  def up
    # Remove columns from pharmacy products
    remove_column :sephcocco_pharmacy_products, :image_url, :string
    remove_column :sephcocco_pharmacy_products, :other_images, :string, array: true

    # Remove columns from restaurant products
    remove_column :sephcocco_restaurant_products, :image_url, :string
    remove_column :sephcocco_restaurant_products, :other_images, :string, array: true

    # Remove columns from lounge products
    remove_column :sephcocco_lounge_products, :image_url, :string
    remove_column :sephcocco_lounge_products, :other_images, :string, array: true
  end

  def down
    # Add back columns to pharmacy products
    add_column :sephcocco_pharmacy_products, :image_url, :string
    add_column :sephcocco_pharmacy_products, :other_images, :string, array: true, default: []

    # Add back columns to restaurant products
    add_column :sephcocco_restaurant_products, :image_url, :string
    add_column :sephcocco_restaurant_products, :other_images, :string, array: true, default: []

    # Add back columns to lounge products
    add_column :sephcocco_lounge_products, :image_url, :string
    add_column :sephcocco_lounge_products, :other_images, :string, array: true, default: []
  end
end 