class Restaurant::User::SephcoccoRestaurantProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :out_of_stock_status,
              :likes,
              :price,
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
    object.sephcocco_restaurant_product_categories.map do |category|
      Restaurant::User::SephcoccoRestaurantProductCategorySerializer.new(category)
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
