class CreateRestaurantSephcoccoRestaurantAdminNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :restaurant_sephcocco_restaurant_admin_notifications do |t|
      t.timestamps
    end
  end
end
