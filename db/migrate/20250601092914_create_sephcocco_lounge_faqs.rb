class CreateSephcoccoLoungeFaqs < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_lounge_faqs, id: :uuid do |t|
      t.string :title, null: false
      t.text :answer
      t.boolean :visibility, default: true
      t.text :update_history

      t.timestamps
    end
  end

  def down
    drop_table :sephcocco_lounge_faqs
  end
end
