class Lounge::Admin::SephcoccoLoungeOrderSerializer < ActiveModel::Serializer
  attributes  :id,
              :sephcocco_user_id,
              :status,
              :stages,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at,
              :product

    def product
      prod = object.sephcocco_lounge_product
      return nil unless prod
      {
        id: prod.id,
        name: prod.name,
        main_image_url: prod.main_image_url,
      }
    end
end
