class RenameUserForeignKeyInMessages < ActiveRecord::Migration[7.2]
  def change
    # Rename foreign key columns in message tables
    rename_column :sephcocco_lounge_messages, :sephcocco_users_id, :sephcocco_user_id
    rename_column :sephcocco_pharmacy_messages, :sephcocco_users_id, :sephcocco_user_id
    rename_column :sephcocco_restaurant_messages, :sephcocco_users_id, :sephcocco_user_id
    
    # Update indexes
    rename_index :sephcocco_lounge_messages, :index_sephcocco_lounge_messages_on_sephcocco_users_id, :index_sephcocco_lounge_messages_on_sephcocco_user_id
    rename_index :sephcocco_pharmacy_messages, :pharmacy_messages_on_sephcocco_users, :index_sephcocco_pharmacy_messages_on_sephcocco_user_id
    rename_index :sephcocco_restaurant_messages, :restaurant_messages_on_sephcocco_users, :index_sephcocco_restaurant_messages_on_sephcocco_user_id
    
    # Update foreign key constraints
    remove_foreign_key :sephcocco_lounge_messages, column: :sephcocco_user_id
    remove_foreign_key :sephcocco_pharmacy_messages, column: :sephcocco_user_id
    remove_foreign_key :sephcocco_restaurant_messages, column: :sephcocco_user_id
    
    add_foreign_key :sephcocco_lounge_messages, :sephcocco_users, column: :sephcocco_user_id
    add_foreign_key :sephcocco_pharmacy_messages, :sephcocco_users, column: :sephcocco_user_id
    add_foreign_key :sephcocco_restaurant_messages, :sephcocco_users, column: :sephcocco_user_id
  end
end 