class Pharmacy::Admin::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :likes,
              :visible,
              :out_of_stock_status,
              :price,
              :categories,
              :created_at,
              :updated_at,

  def categories
    object.sephcocco_pharmacy_product_categories.map do |category|
      Pharmacy::Admin::SephcoccoPharmacyProductCategorySerializer.new(category)
    end
  end

  def image_url
    return nil unless object.image_url.attached?
    Rails.application.routes.url_helpers.rails_blob_url(object.image_url)
  end
  
  def other_images
    return [] unless object.other_images.attached?
    object.other_images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_url(image)
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
