class Pharmacy::Admin::SephcoccoPharmacyProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :products,
              :description,
              :created_at,
              :updated_at


  def products
    object.sephcocco_pharmacy_products.map do |product|
      Pharmacy::Admin::SephcoccoPharmacyProductSerializer.new(product).as_json
    end
  end
end
