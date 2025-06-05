class AddResetPasswordToSephcoccoUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :sephcocco_users, :reset_password_token, :string
    add_column :sephcocco_users, :reset_password_sent_at, :datetime
  end

  def down
    remove_column :sephcocco_users, :reset_password_token
    remove_column :sephcocco_users, :reset_password_sent_at
  end
end
