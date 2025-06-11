class Lounge::Admin::SephcoccoLoungeProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :total_products,
              :description,
              :created_at,
              :updated_at


  def total_products
    object.sephcocco_lounge_products.count || 0
  end
end
