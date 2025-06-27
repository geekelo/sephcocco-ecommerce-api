require_relative '../../lib/migration_helpers/order_stages_type_migration_helper'

class ChangeStagesToJsonbInSephcoccoLoungeOrders < ActiveRecord::Migration[7.2]
  include MigrationHelpers::OrderStagesTypeMigrationHelper

  def up
    change_order_stages_type_to_jsonb :sephcocco_lounge_orders
  end

  def down
    change_order_stages_type_to_string :sephcocco_lounge_orders
  end
end
