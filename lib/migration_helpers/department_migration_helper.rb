module MigrationHelpers
  module DepartmentMigrationHelper
    def create_department_table(prefix:)
      create_table "sephcocco_#{prefix}_departments", id: :uuid do |t|
        t.string :name, null: false
        t.text :address
        t.boolean :active, default: true, null: false

        t.references :"sephcocco_#{prefix}_product", null: false, foreign_key: true, type: :uuid
        t.references :"sephcocco_#{prefix}_order", null: false, foreign_key: true, type: :uuid
        t.references :"sephcocco_#{prefix}_stock_management", null: false, foreign_key: true, type: :uuid
        t.references :"sephcocco_#{prefix}_payment", null: false, foreign_key: true, type: :uuid
        t.timestamps
      end
      
      add_index "sephcocco_#{prefix}_departments", :name, unique: true
      add_index "sephcocco_#{prefix}_departments", :active
    end

    def drop_department_table(prefix:)
      drop_table "sephcocco_#{prefix}_departments"
    end
  end
end
