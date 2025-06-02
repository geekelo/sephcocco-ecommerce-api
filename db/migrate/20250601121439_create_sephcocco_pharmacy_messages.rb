require_relative '../../lib/migration_helpers/messages_migration_helper'

class CreateSephcoccoPharmacyMessages < ActiveRecord::Migration[7.2]
  include MigrationHelpers::MessagesMigrationHelper

  def up
   create_messages_table(
    table_name: :sephcocco_pharmacy_messages,
    user_table: :sephcocco_users,
    product_table: :sephcocco_pharmacy_products,
   )
  end

  def down
    drop_table :sephcocco_pharmacy_messages
  end
end
