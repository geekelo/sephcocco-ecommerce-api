module MigrationHelpers
  module FaqMigrationHelper
def create_faq_table(faq_table_name, category_table_name, category_reference_column)
      create_table faq_table_name, id: :uuid do |t|
        t.string :title, null: false
        t.text :answer
        t.boolean :visibility, default: false, null: false
        t.integer :position, null: false, default: 0
        t.jsonb :update_history, default: {}, null: false

        t.references category_reference_column, null: false,
                     foreign_key: { to_table: category_table_name },
                     type: :uuid
        t.timestamps
      end
    end

    def drop_faq_table(table_name)
      drop_table table_name
    end
  end
end
