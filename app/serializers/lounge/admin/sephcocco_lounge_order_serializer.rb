class Lounge::Admin::SephcoccoLoungeOrderSerializer < ActiveModel::Serializer
  attributes  :id,
              :sephcocco_user_id,
              :status,
              :stages,
              :current_stage,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at,
              :product,
              :customer,
              :address,
              :phone_number,
              :additional_notes,

    def product
      object&.sephcocco_lounge_product
    end

  def customer
    object&.sephcocco_user
  end
end
