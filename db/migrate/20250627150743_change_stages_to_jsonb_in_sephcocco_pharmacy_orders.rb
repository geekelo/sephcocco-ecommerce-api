require_relative '../../lib/migration_helpers/order_stages_type_migration_helper'

class ChangeStagesToJsonbInSephcoccoPharmacyOrders < ActiveRecord::Migration[7.2]
  include MigrationHelpers::OrderStagesTypeMigrationHelper

  def up
    change_order_stages_type_to_jsonb :sephcocco_pharmacy_orders
  end

  def down
    change_order_stages_type_to_string :sephcocco_pharmacy_orders
  end
end
