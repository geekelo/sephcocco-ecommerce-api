require_relative '../../lib/migration_helpers/department_migration_helper'

class CreateDepartments < ActiveRecord::Migration[7.2]
  include MigrationHelpers::DepartmentMigrationHelper

  def up
    # Create department tables for all three outlets
    create_department_table(prefix: 'lounge')
    create_department_table(prefix: 'pharmacy')
    create_department_table(prefix: 'restaurant')
  end

  def down
    # Drop department tables for all three outlets
    drop_department_table(prefix: 'lounge')
    drop_department_table(prefix: 'pharmacy')
    drop_department_table(prefix: 'restaurant')
  end
end
