require_relative '../../lib/migration_helpers/messages_migration_helper'

class CreateSephcoccoRestaurantMessages < ActiveRecord::Migration[7.2]
  include MigrationHelpers::MessagesMigrationHelper

  def up
   create_messages_table(
    table_name: :sephcocco_restaurant_messages,
    user_table: :sephcocco_users,
    product_table: :sephcocco_restaurant_products,
    table_name_suffix: 'restaurant_messages'
   )
  end

  def down
    drop_table :sephcocco_restaurant_messages
  end
end
