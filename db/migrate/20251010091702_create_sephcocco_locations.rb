class CreateSephcoccoLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :sephcocco_locations do |t|
      t.string :location, null: false
      t.decimal :logistics_price, precision: 16, scale: 2, null: false

      t.timestamps
    end

    add_index :sephcocco_locations, :location
    add_index :sephcocco_locations, :logistics_price
  end
end
