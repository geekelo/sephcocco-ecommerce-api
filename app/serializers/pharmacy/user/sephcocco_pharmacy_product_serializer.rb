class Pharmacy::User::SephcoccoPharmacyProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :short_description,
              :long_description,
              :amount_in_stock,
              :likes,
              :liked_by_user,
              :price,
              :discount_price,
              :out_of_stock_status,
              :main_image_url,
              :other_image_urls,
              :barcode,
              :department,
              :categories,
              :created_at,
              :updated_at,

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

  def liked_by_user
    user = scope
    return false unless user
    object&.sephcocco_pharmacy_product_likes&.exists?(sephcocco_user_id: user.id)
  end

  def department
    return nil unless object.sephcocco_pharmacy_department.present?
    {
      id: object.sephcocco_pharmacy_department.id,
      name: object.sephcocco_pharmacy_department.name
    }
  end
end
