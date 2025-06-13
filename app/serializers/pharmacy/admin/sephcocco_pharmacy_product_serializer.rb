class Pharmacy::Admin::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :short_description,
              :long_description,
              :amount_in_stock,
              :likes,
              :visible,
              :out_of_stock_status,
              :price,
              :categories,
              :created_at,
              :updated_at,
              :main_image_url,
              :other_images_urls,

  def categories
    object.sephcocco_pharmacy_product_categories.map do |category|
      Pharmacy::Admin::SephcoccoPharmacyProductCategorySerializer.new(category)
    end
  end

  def main_image_url
    return nil unless object.image_url.attached?
    Rails.application.routes.url_helpers.rails_blob_path(object.image_url, only_path: true)
  end

  def other_images_urls
    return [] unless object.other_images.attached?
    object.other_images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end

  def out_of_stock_status
    if object.amount_in_stock > 0
      false
    else
      true
    end
  end
end
