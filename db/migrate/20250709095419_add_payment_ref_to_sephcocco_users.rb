class AddPaymentRefToSephcoccoUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :sephcocco_users, :payment_ref, :string, default: "0001"
  end

  def down
    remove_column :sephcocco_users, :payment_ref
  end
end
