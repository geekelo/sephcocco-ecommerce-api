# app/models/concerns/order_model_helper.rb
module OrderModelHelper
  extend ActiveSupport::Concern

  included do
    before_create :set_order_status
    # before_create :set_order_number
    before_create :set_shipping_details, if: -> { respond_to?(:set_shipping_details, true) }
  end

  def update_stages(status)
    stage_date = DateTime.now
    self.stages.push({"status": status, "date": stage_date})
    self.current_stage = status
    self.save!
  end

  def set_order_total(unit_price = nil, quantity = nil)
    # Use instance variables if parameters not provided
    unit_price ||= self.unit_price
    quantity ||= self.quantity
    
    if unit_price.present? && quantity.present?
      self.total_price = unit_price * quantity
      self.total_cost = total_price
    end

    self.save!
  end

  def set_total_cost(shipping_cost = 0)
    self.total_cost = (self.total_price + shipping_cost).round(2)
    self.save!
  end

  def change_order_status(status)
    stage_date = DateTime.now
    self.status = status
    self.stages.push({"status": status, "date": stage_date})
    self.current_stage = status
    self.save!
  end

  private

  def set_order_status
    self.status = "pending" # ['pending', 'processing', 'completed', 'cancelled']
    self.stages = [ {"status": "pending", "date": DateTime.now} ] #  ['pending', 'processing', 'shipped', 'delivered']
    self.current_stage = "pending"
    self.quantity ||= 1
  end

  # def set_order_number
  #   self.order_number = SecureRandom.uuid
  # end
end
