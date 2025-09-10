class CreateSephcoccoUserSubroles < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_user_subroles, id: :uuid do |t|
      t.string :name
      t.string :description
      t.timestamps
    end

    add_reference :sephcocco_users, :sephcocco_user_subrole, foreign_key: true
  end

  def down
    drop_table :sephcocco_user_subroles
    remove_reference :sephcocco_users, :sephcocco_user_subrole
  end
end
