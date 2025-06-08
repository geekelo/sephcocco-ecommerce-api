# app/models/concerns/order_model_helper.rb
module Api::V1::Concerns::OrderModelHelper
  extend ActiveSupport::Concern

  included do
    before_create :set_order_status
    before_create :set_order_number
    before_create :set_unit_price
    before_create :set_order_total
    before_create :set_shipping_details, if: -> { respond_to?(:set_shipping_details, true) }
  end

  private

  def set_order_status
    self.status = "pending" # ['pending', 'processing', 'completed', 'cancelled']
    self.stages = [ "pending" ] #  ['pending', 'processing', 'shipped', 'delivered']
    self.current_stage = self.stages.last
    self.quantity ||= 1
  end

  def set_order_number
    self.order_number = SecureRandom.uuid
  end

  def set_unit_price
    self.unit_price = product.price if respond_to?(:product) && product.present?
  end

  def set_order_total
    if unit_price.present?
      self.total_price = unit_price * quantity
      self.total_cost = total_price + (shipping_cost || 0)
    end
  end
end
