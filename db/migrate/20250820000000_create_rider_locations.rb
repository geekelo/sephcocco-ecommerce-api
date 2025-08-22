class CreateRiderLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :rider_locations, id: :uuid do |t|
      t.references :rider, null: false, foreign_key: { to_table: :sephcocco_users }, type: :uuid
      t.decimal :latitude, precision: 10, scale: 8, null: false
      t.decimal :longitude, precision: 11, scale: 8, null: false
      t.decimal :accuracy, precision: 5, scale: 2
      t.string :outlet_type
      t.datetime :timestamp, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :rider_locations, [:rider_id, :active]
    add_index :rider_locations, :timestamp
    add_index :rider_locations, :outlet_type
  end
end
