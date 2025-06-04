module MigrationHelpers
  module NotificationMigrationHelper
    def create_notification_table(table_name)
      create_table table_name, id: :uuid do |t|
        t.references :sephcocco_user, null: false, foreign_key: true, type: :uuid
        t.string :action_type, null: false
        t.string :action_id
        t.string :message, null: false
        t.boolean :viewed, default: false, null: false
        t.boolean :visible, default: true, null: false

        t.timestamps
      end
    end

    def drop_notification_table(table_name)
      drop_table table_name
    end
  end

end
