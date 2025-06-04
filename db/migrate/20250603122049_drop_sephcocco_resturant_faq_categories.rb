require Rails.root.join("lib/migration_helpers/faq_category_migration_helper")

class DropSephcoccoResturantFaqCategories < ActiveRecord::Migration[7.2]
  include MigrationHelpers::FaqCategoryMigrationHelper

  def up
    drop_faq_category_table :sephcocco_resturant_faq_categories
  end
end