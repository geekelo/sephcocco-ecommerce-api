require Rails.root.join("lib/migration_helpers/faq_migration_helper")

class CreateSephcoccoLoungeFaqs < ActiveRecord::Migration[7.2]
  include MigrationHelpers::FaqMigrationHelper

  def up
    create_faq_table(
      :sephcocco_lounge_faqs,
      :sephcocco_lounge_faq_categories,
      :sephcocco_lounge_faq_category
    )
  end

  def down
    drop_faq_table :sephcocco_lounge_faqs
  end
end
