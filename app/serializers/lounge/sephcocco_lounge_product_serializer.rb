class Lounge::SephcoccoLoungeProductSerializer < ActiveModel::Serializer
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
              :updated_at

  def categories
    return [] unless object.sephcocco_lounge_product_categories.any?
    object.sephcocco_lounge_product_categories.map do |category|
      {
        id: category.id, 
        name: category.name,
        description: category.description,
        slug: category.slug,
      }
    end
  end

  def out_of_stock_status
    if object.amount_in_stock > 0
      false
    else
      true
    end
  end

  def image_url
    return nil unless object.image_url.attached?
    Rails.application.routes.url_helpers.rails_blob_url(object.image_url, host: ENV['API_HOST'] || 'localhost:3000')
  end

  def other_images
    return [] unless object.other_images.attached?
    object.other_images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_url(image, host: ENV['API_HOST'] || 'localhost:3000')
    end
  end
end
