require_relative '../../lib/migration_helpers/notification_migration_helper'

class CreateSephcoccoLoungeAdminNotifications < ActiveRecord::Migration[7.2]
  include MigrationHelpers::NotificationMigrationHelper

  def up
    create_notification_table :sephcocco_lounge_admin_notifications
  end

  def down
    drop_notification_table :sephcocco_lounge_admin_notifications
  end

end
