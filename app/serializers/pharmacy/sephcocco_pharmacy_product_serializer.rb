class Pharmacy::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :likes,
              :price,
              :categories,
              :created_at,
              :updated_at

  def categories
    object.sephcocco_pharmacy_product_categories.map do |category|
      {
      id: category.id, 
      name: category.name,
      description: category.description,
      slug: category.slug,
    }
    end
  end

  def image_url
    return nil unless object.image_url.attached?
    Rails.application.routes.url_helpers.rails_blob_url(object.image_url, only_path: true)
  end

  def other_images
    return [] unless object.other_images.attached?
    object.other_images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
    end
  end
end
