class Pharmacy::User::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :short_description,
              :long_description,
              :amount_in_stock,
              :likes,
              :price,
              :out_of_stock_status,
              :categories,
              :created_at,
              :updated_at,
              :single_image_url,
              :other_images_urls

  def single_image_url
    return nil unless object.image_key.present?
    "https://#{ENV['CLOUDFLARE_R2_BUCKET']}.r2.cloudflarestorage.com/#{object.image_key}"
  end

  def other_images_urls
    return [] unless object.other_image_keys.present?
    object.other_image_keys.map do |key|
      "https://#{ENV['CLOUDFLARE_R2_BUCKET']}.r2.cloudflarestorage.com/#{key}"
    end
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
