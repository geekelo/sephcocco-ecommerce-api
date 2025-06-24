require_relative '../../lib/migration_helpers/order_additional_fields_helper'

class AddAdditionalFieldsToSephcoccoPharmacyOrders < ActiveRecord::Migration[7.0]
  include MigrationHelpers::OrderAdditionalFieldsHelper

  def up
    add_order_additional_fields :sephcocco_pharmacy_orders
  end

  def down
    remove_order_additional_fields :sephcocco_pharmacy_orders
  end
end 