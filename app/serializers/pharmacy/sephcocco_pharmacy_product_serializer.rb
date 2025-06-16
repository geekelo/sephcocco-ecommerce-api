class Pharmacy::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :short_description,
              :long_description,
              :amount_in_stock,
              :out_of_stock_status,
              :likes,
              :price,
              :main_image_url,
              :other_image_urls,
              :visible,
              :categories,
              :created_at,
              :updated_at

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
