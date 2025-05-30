require_relative '../../lib/migration_helpers/image_urls_column_helper'

class AddImageUrlsToSephcoccoPharmacyProducts < ActiveRecord::Migration[7.2]
  include MigrationHelpers::ImageUrlsColumnHelper

  def up
    add_image_urls_column('sephcocco_pharmacy_products')
  end

  def down
    remove_image_urls_column('sephcocco_pharmacy_products')
  end
end
