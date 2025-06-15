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
              :single_image_url,
              :other_images_urls

  def single_image_url
    object&.image_url
  end

  def other_images_urls
    object&.other_images
  end

  def categories
    return [] unless object.sephcocco_pharmacy_product_categories.any?
    object.sephcocco_pharmacy_product_categories.map do |category|
      {
        id: category.id, 
        name: category.name,
        description: category.description,
        slug: category.slug
      }
    end
  end

  def out_of_stock_status
    object.amount_in_stock <= 0
  end
end
