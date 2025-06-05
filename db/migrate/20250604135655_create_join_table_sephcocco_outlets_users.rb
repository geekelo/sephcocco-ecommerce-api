class CreateJoinTableSephcoccoOutletsUsers < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_outlets_users, id: false do |t|
      t.uuid :sephcocco_user_id, null: false
      t.uuid :sephcocco_outlet_id, null: false
    end

    add_index :sephcocco_outlets_users, [ :sephcocco_user_id, :sephcocco_outlet_id ], unique: true, name: 'index_outlets_users_on_user_id_and_outlet_id'

    add_foreign_key :sephcocco_outlets_users, :sephcocco_users
    add_foreign_key :sephcocco_outlets_users, :sephcocco_outlets
  end

  def down
    remove_foreign_key :sephcocco_outlets_users, :sephcocco_users
    remove_foreign_key :sephcocco_outlets_users, :sephcocco_outlets
    drop_table :sephcocco_outlets_users
  end
end
