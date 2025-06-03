# class CreateSephcoccoRestaurantFaqs < ActiveRecord::Migration[7.2]
#   def change
#     create_table :sephcocco_restaurant_faqs do |t|
#       t.timestamps
#     end
#   end
# end

require Rails.root.join("lib/migration_helpers/faq_migration_helper")

class CreateCreateSephcoccoRestaurantFaqs < ActiveRecord::Migration[7.2]
    include MigrationHelpers::FaqMigrationHelper

  def up
    create_faq_table(
      :sephcocco_restaurant_faqs,
      :sephcocco_restaurant_faq_categories,
      :sephcocco_restaurant_category,
    )

    def down
      drop_faq_table :sephcocco_restaurant_faqs
    end
  end
end
