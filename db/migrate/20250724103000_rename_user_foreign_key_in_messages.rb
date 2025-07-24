class RenameUserForeignKeyInMessages < ActiveRecord::Migration[7.2]
  def up
    # Rename foreign key columns in message tables
    rename_column :sephcocco_lounge_messages, :sephcocco_users_id, :sephcocco_user_id
    rename_column :sephcocco_pharmacy_messages, :sephcocco_users_id, :sephcocco_user_id
    rename_column :sephcocco_restaurant_messages, :sephcocco_users_id, :sephcocco_user_id
    
    # Update indexes safely
    if index_exists?(:sephcocco_lounge_messages, :sephcocco_user_id, name: "index_sephcocco_lounge_messages_on_sephcocco_users_id")
      rename_index :sephcocco_lounge_messages, "index_sephcocco_lounge_messages_on_sephcocco_users_id", "index_sephcocco_lounge_messages_on_sephcocco_user_id"
    end
    
    if index_exists?(:sephcocco_pharmacy_messages, :sephcocco_user_id, name: "pharmacy_messages_on_sephcocco_users")
      rename_index :sephcocco_pharmacy_messages, "pharmacy_messages_on_sephcocco_users", "index_sephcocco_pharmacy_messages_on_sephcocco_user_id"
    end
    
    if index_exists?(:sephcocco_restaurant_messages, :sephcocco_user_id, name: "restaurant_messages_on_sephcocco_users")
      rename_index :sephcocco_restaurant_messages, "restaurant_messages_on_sephcocco_users", "index_sephcocco_restaurant_messages_on_sephcocco_user_id"
    end
    
    # Update foreign key constraints safely
    if foreign_key_exists?(:sephcocco_lounge_messages, column: :sephcocco_user_id)
      remove_foreign_key :sephcocco_lounge_messages, column: :sephcocco_user_id
    end
    if foreign_key_exists?(:sephcocco_pharmacy_messages, column: :sephcocco_user_id)
      remove_foreign_key :sephcocco_pharmacy_messages, column: :sephcocco_user_id
    end
    if foreign_key_exists?(:sephcocco_restaurant_messages, column: :sephcocco_user_id)
      remove_foreign_key :sephcocco_restaurant_messages, column: :sephcocco_user_id
    end
    
    add_foreign_key :sephcocco_lounge_messages, :sephcocco_users, column: :sephcocco_user_id
    add_foreign_key :sephcocco_pharmacy_messages, :sephcocco_users, column: :sephcocco_user_id
    add_foreign_key :sephcocco_restaurant_messages, :sephcocco_users, column: :sephcocco_user_id
  end

  def down
    # Revert foreign key constraints
    remove_foreign_key :sephcocco_lounge_messages, column: :sephcocco_user_id
    remove_foreign_key :sephcocco_pharmacy_messages, column: :sephcocco_user_id
    remove_foreign_key :sephcocco_restaurant_messages, column: :sephcocco_user_id
    
    add_foreign_key :sephcocco_lounge_messages, :sephcocco_users, column: :sephcocco_users_id
    add_foreign_key :sephcocco_pharmacy_messages, :sephcocco_users, column: :sephcocco_users_id
    add_foreign_key :sephcocco_restaurant_messages, :sephcocco_users, column: :sephcocco_users_id
    
    # Revert indexes
    if index_exists?(:sephcocco_lounge_messages, :sephcocco_user_id, name: "index_sephcocco_lounge_messages_on_sephcocco_user_id")
      rename_index :sephcocco_lounge_messages, "index_sephcocco_lounge_messages_on_sephcocco_user_id", "index_sephcocco_lounge_messages_on_sephcocco_users_id"
    end
    
    if index_exists?(:sephcocco_pharmacy_messages, :sephcocco_user_id, name: "index_sephcocco_pharmacy_messages_on_sephcocco_user_id")
      rename_index :sephcocco_pharmacy_messages, "index_sephcocco_pharmacy_messages_on_sephcocco_user_id", "pharmacy_messages_on_sephcocco_users"
    end
    
    if index_exists?(:sephcocco_restaurant_messages, :sephcocco_user_id, name: "index_sephcocco_restaurant_messages_on_sephcocco_user_id")
      rename_index :sephcocco_restaurant_messages, "index_sephcocco_restaurant_messages_on_sephcocco_user_id", "restaurant_messages_on_sephcocco_users"
    end
    
    # Revert column names
    rename_column :sephcocco_lounge_messages, :sephcocco_user_id, :sephcocco_users_id
    rename_column :sephcocco_pharmacy_messages, :sephcocco_user_id, :sephcocco_users_id
    rename_column :sephcocco_restaurant_messages, :sephcocco_user_id, :sephcocco_users_id
  end
end 