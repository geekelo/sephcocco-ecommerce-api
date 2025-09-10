class CreateJoinTableSephcoccoUserSubrolesUsers < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_user_subroles_users, id: :uuid do |t|
      t.uuid :sephcocco_user_id, null: false
      t.uuid :sephcocco_user_subrole_id, null: false
    end

    add_index :sephcocco_user_subroles_users, [ :sephcocco_user_id, :sephcocco_user_subrole_id ], unique: true, name: 'index_user_subroles_users_on_user_id_and_subrole_id'

    add_foreign_key :sephcocco_user_subroles_users, :sephcocco_users, column: :sephcocco_user_id
    add_foreign_key :sephcocco_user_subroles_users, :sephcocco_user_subroles, column: :sephcocco_user_subrole_id
  end

  def down
    remove_foreign_key :sephcocco_user_subroles_users, :sephcocco_users
    remove_foreign_key :sephcocco_user_subroles_users, :sephcocco_user_subroles
    drop_table :sephcocco_user_subroles_users
  end
end
