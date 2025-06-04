class CreateSephcoccoPharmacyFaqs < ActiveRecord::Migration[7.2]
  def change
    create_table :sephcocco_pharmacy_faqs do |t|
      t.timestamps
    end
  end
end

require Rails.root.join("lib/migration_helpers/faq_migration_helper")

class CreateSephcoccoPharmacyFaqs < ActiveRecord::Migration[7.2]
  include MigrationHelpers::FaqMigrationHelper

  def up
    create_faq_table(
      :sephcocco_pharmacy_faqs,
      :sephcocco_pharmacy_faq_categories,
      :sephcocco_pharmacy_faq_category
    )
  end

  def down
    drop_faq_table :sephcocco_pharmacy_faqs
  end
end
