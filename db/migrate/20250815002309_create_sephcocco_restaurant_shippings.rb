class CreateSephcoccoRestaurantShippings < ActiveRecord::Migration[7.2]
  def change
    create_table :sephcocco_restaurant_shippings, id: :uuid do |t|
      t.string :tracking_number
      t.string :status
      t.datetime :datetime_delivered
      t.boolean :dispatching, default: false
      t.references :sephcocco_restaurant_order, null: false, foreign_key: true, type: :uuid
      t.references :rider, null: true, foreign_key: { to_table: :sephcocco_users }, type: :uuid

      t.timestamps
    end
  end
end
