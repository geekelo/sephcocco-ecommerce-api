module MigrationHelpers
  module FaqCategoryMigrationHelper

    def create_faq_category_table(table_name)
      create_table table_name, id: :uuid do |t|
        t.string :title, null: false
        t.text :description
        t.boolean :visibility, default: false, null: false
        t.integer :position, null: false, default: 0
        t.timestamps
      end
    end

    def drop_faq_category_table(table_name)
      drop_table table_name
    end
  end
end
