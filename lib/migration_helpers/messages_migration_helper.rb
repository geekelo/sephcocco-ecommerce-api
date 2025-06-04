module MigrationHelpers
  module MessagesMigrationHelper
    def create_messages_table(table_name:, user_table:, product_table:)
      create_table table_name do |t|
        t.references product_table, polymorphic: true, type: :uuid, null: true, index: { name: "index_#{table_name}_on_#{product_table}_type_and_id" }
        t.references user_table, null: false, type: :uuid, foreign_key: { to_table: user_table }, index: { name: "index_#{table_name}_on_#{user_table}_id" }
        t.jsonb :chats, default: []
        t.jsonb :status_history, array: true, default: []
        t.string :status, default: "open", null: false

        t.timestamps
      end
    end
  end
end
