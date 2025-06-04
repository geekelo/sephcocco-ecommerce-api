class CreateSephcoccoOutlets < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_outlets, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
  end

  def down
    drop_table :sephcocco_outlets
  end
end
