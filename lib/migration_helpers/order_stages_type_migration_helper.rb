# lib/migration_helpers/order_stages_type_migration_helper.rb

module MigrationHelpers
    module OrderStagesTypeMigrationHelper
        def change_order_stages_type_to_jsonb(table_name)
            remove_column table_name, :stages
            add_column table_name, :stages, :jsonb, default: []
        end

        def change_order_stages_type_to_string(table_name)
            remove_column table_name, :stages
            add_column table_name, :stages, :string, array: true, default: []
        end
    end
  end
  