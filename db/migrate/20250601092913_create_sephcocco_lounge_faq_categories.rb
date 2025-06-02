class CreateSephcoccoLoungeFaqCategories < ActiveRecord::Migration[7.2]
  def up
    create_table :sephcocco_lounge_faq_categories do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :visibility, default: false, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end

  def down
    drop_table :sephcocco_lounge_faq_categories
  end
end
