class Pharmacy::Admin::SephcoccoPharmacyProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :total_products,
              :description,
              :created_at,
              :updated_at


   def total_products
    object&.sephcocco_pharmacy_products&.count || 0
  end
end
