require_relative '../../lib/migration_helpers/order_stages_type_migration_helper'

class ChangeStagesToJsonbInSephcoccoRestaurantOrders < ActiveRecord::Migration[7.2]
  include MigrationHelpers::OrderStagesTypeMigrationHelper

  def up
    change_order_stages_type_to_jsonb :sephcocco_restaurant_orders
  end

  def down
    change_order_stages_type_to_string :sephcocco_restaurant_orders
  end
end
