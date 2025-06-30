module MigrationHelpers
  module OrderAdditionalFieldsHelper
    def add_order_additional_fields(table_name)
      add_column table_name, :phone_number, :string
      add_column table_name, :additional_notes, :text
    end

    def remove_order_additional_fields(table_name)
      remove_column table_name, :address
      remove_column table_name, :phone_number
      remove_column table_name, :additional_notes
    end
  end
end 