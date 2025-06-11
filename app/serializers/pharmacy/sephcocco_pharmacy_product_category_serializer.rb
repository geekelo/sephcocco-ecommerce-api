class Pharmacy::SephcoccoPharmacyProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :description,
              :total_products,
              :created_at,
              :updated_at

   def total_products
    object&.pharmacy_products&.count || 0
  end
end
