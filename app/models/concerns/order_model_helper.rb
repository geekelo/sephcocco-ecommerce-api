# app/models/concerns/order_model_helper.rb
module OrderModelHelper
  extend ActiveSupport::Concern

  included do
    before_create :set_order_status
    before_create :set_order_number
    before_create :set_order_total
    before_create :set_shipping_details, if: -> { respond_to?(:set_shipping_details, true) }
  end

  private

  def set_order_status
    self.status = "pending" # ['pending', 'processing', 'completed', 'cancelled']
    self.stages = [ {"status": "pending", "date": DateTime.now} ] #  ['pending', 'processing', 'shipped', 'delivered']
    self.current_stage = "pending"
    self.quantity ||= 1
  end

  def set_order_number
    self.order_number = SecureRandom.uuid
  end

  def self.update_stages(status)
    if status == "refunded" || status == "delivered"
      self.stages.push({"status": status, "date": DateTime.now})
    else
      self.stages.push({"status": status, "date": DateTime.now})
    end
    self.current_stage = self.stages.last.status
    self.save!
  end

  def set_order_total
    if unit_price.present?
      self.total_price = unit_price * quantity
      self.total_cost = total_price
    end
  end

  def set_total_cost(shipping_cost = 0)
    self.total_cost = (self.total_price + shipping_cost).round(2)
    self.save!
  end
end
