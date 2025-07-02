class CreateSephcoccoRestaurantAdminActivity < ActiveRecord::Migration[7.2]
  include MigrationHelpers::AdminActivityMigrationHelper

  def up
    create_admin_activity_table :sephcocco_restaurant_admin_activities
  end

  def down
    drop_admin_activity_table :sephcocco_restaurant_admin_activities
  end
end
