require_relative '../../lib/migration_helpers/image_urls_column_helper'

class AddImageUrlsToSephcoccoLoungeProducts < ActiveRecord::Migration[7.2]
  include MigrationHelpers::ImageUrlsColumnHelper

  def up
    add_image_urls_column('sephcocco_lounge_products')
  end

  def down
    remove_image_urls_column('sephcocco_lounge_products')
  end
end
