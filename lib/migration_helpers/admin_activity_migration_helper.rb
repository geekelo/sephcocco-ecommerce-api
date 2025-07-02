module MigrationHelpers
  module AdminActivityMigrationHelper
    def create_admin_activity_table(table_name)
      create_table table_name, id: :uuid do |t|
        t.references :sephcocco_user, type: :uuid, null: false, foreign_key: true
        t.string :activity_type
        t.string :activity_name
        t.string :activity_description

        t.timestamps
      end
    end

    def drop_admin_activity_table(table_name)
      drop_table table_name
    end
  end
end
