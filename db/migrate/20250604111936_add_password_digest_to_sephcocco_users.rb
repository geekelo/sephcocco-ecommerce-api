class AddPasswordDigestToSephcoccoUsers < ActiveRecord::Migration[7.2]
def up
    add_column :sephcocco_users, :password_digest, :string, null: true
  end

  def down
    remove_column :sephcocco_users, :password_digest
  end
end
