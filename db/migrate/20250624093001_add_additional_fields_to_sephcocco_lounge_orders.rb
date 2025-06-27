require_relative '../../lib/migration_helpers/order_additional_fields_helper'

class AddAdditionalFieldsToSephcoccoLoungeOrders < ActiveRecord::Migration[7.0]
  include MigrationHelpers::OrderAdditionalFieldsHelper

  def up
    add_order_additional_fields :sephcocco_lounge_orders
  end

  def down
    remove_order_additional_fields :sephcocco_lounge_orders
  end
end 