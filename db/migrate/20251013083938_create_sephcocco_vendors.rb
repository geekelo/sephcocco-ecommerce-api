class CreateSephcoccoVendors < ActiveRecord::Migration[7.2]
  def up
    # Create department tables for all three outlets
    create_vendor_table(prefix: 'lounge')
    create_vendor_table(prefix: 'pharmacy')
    create_vendor_table(prefix: 'restaurant')
  end

  def down
    # Drop department tables for all three outlets
    drop_vendor_table(prefix: 'lounge')
    drop_vendor_table(prefix: 'pharmacy')
    drop_vendor_table(prefix: 'restaurant')
  end
end
