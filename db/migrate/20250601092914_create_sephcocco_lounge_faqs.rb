class CreateSephcoccoLoungeFaqs < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_lounge_faqs, id: :uuid do |t|
      t.string :title, null: false
      t.text :answer
      t.boolean :visibility, default: false, null: false
      t.integer :position, null: false, default: 0
      t.jsonb :update_history, default: {}, null: false

      t.references :sephcocco_lounge_faq_category, null: false, foreign_key: { to_table: :sephcocco_lounge_faq_categories }, type: :uuid
      t.timestamps
    end
  end

  def down
    drop_table :sephcocco_lounge_faqs
  end
end
