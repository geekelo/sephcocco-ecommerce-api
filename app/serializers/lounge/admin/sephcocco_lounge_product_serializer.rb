class Lounge::Admin::SephcoccoLoungeProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :likes,
              :visible,
              :price,
              :out_of_stock_status,
              :categories,
              :created_at,
              :updated_at,

  def categories
    object.sephcocco_lounge_product_categories.map do |category|
      Lounge::Admin::SephcoccoLoungeProductCategorySerializer.new(category)
    end
  end

  def image_url
    return nil unless object.image_url.attached?
    Rails.application.routes.url_helpers.rails_blob_path(object.image_url, only_path: true)
  end

  def other_images
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
