require Rails.root.join("lib/migration_helpers/faq_category_migration_helper")

class CreateSephcoccoLoungeFaqCategories < ActiveRecord::Migration[7.2]
  include MigrationHelpers::FaqCategoryMigrationHelper

  def up
    create_faq_category_table :sephcocco_lounge_faq_categories
  end

  def down
    drop_faq_category_table :sephcocco_lounge_faq_categories
  end
end
