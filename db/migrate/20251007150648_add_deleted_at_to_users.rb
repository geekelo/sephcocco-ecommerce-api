class AddDeletedAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :sephcocco_users, :deleted_at, :datetime
    add_index :sephcocco_users, :deleted_at
  end
end
