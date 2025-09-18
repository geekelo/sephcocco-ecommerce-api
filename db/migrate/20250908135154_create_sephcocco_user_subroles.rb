class CreateSephcoccoUserSubroles < ActiveRecord::Migration[7.2]
  def change
    create_table :sephcocco_user_subroles, id: :uuid do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end
