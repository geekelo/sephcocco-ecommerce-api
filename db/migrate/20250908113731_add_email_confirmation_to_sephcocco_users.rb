class AddEmailConfirmationToSephcoccoUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :sephcocco_users, :email_confirmation_token, :string
    add_column :sephcocco_users, :email_confirmation_sent_at, :datetime
    add_column :sephcocco_users, :email_confirmed, :boolean, default: false
  end

  def down
    remove_column :sephcocco_users, :email_confirmation_token
    remove_column :sephcocco_users, :email_confirmation_sent_at
    remove_column :sephcocco_users, :email_confirmed
  end
end
