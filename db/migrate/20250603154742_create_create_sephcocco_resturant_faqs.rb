require Rails.root.join("lib/migration_helpers/faq_migration_helper")

class CreateCreateSephcoccoResturantFaqs < ActiveRecord::Migration[7.2]
    include MigrationHelpers::FaqMigrationHelper

  def up
    create_faq_table(
      :sephcocco_resturant_faqs,
      :sephcocco_resturant_faq_categories,
      :sephcocco_resturant_category,
    )

    def down
      drop_faq_table :sephcocco_resturant_faqs
    end
  end
end
