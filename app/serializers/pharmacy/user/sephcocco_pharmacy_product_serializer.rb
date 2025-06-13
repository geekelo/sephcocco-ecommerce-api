class Pharmacy::User::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
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
    object.sephcocco_pharmacy_product_categories.map do |category|
      { id: category.id, name: category.name }
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
