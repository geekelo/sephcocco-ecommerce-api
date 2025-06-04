class AddSuspendedAndLastLoginAtToSephcoccoUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :sephcocco_users, :suspended, :boolean, default: false
    add_column :sephcocco_users, :last_login_at, :datetime
  end

  def down
    remove_column :sephcocco_users, :last_login_at
    remove_column :sephcocco_users, :suspended
  end
end
