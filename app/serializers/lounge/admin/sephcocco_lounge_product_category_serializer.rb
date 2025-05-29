class Lounge::Admin::SephcoccoLoungeProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :products,
              :description,
              :created_at,
              :updated_at
 
 
  def products
    object.sephcocco_lounge_products.map do |product|
      Lounge::Admin::SephcoccoLoungeProductSerializer.new(product).as_json
    end
  end
end
