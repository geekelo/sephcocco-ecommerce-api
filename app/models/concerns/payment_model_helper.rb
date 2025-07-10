module PaymentModelHelper
  extend ActiveSupport::Concern

  included do
    before_create :set_default_status
    # after_save :set_status
    # Temporarily disabled to debug the "can't cast Hash" error
    # after_save :update_order_status
  end

  private

  def set_default_status
    self.status ||= "pending"
    self.status_history ||= []
    self.status_history << { "pending" => Time.current } unless status_history.any? { |h| h.key?("pending") }
  end

  def set_status
    if saved_change_to_status? && status.present?
      key = status.to_s
      idx = status_history.index { |h| h.key?(key) }

      if idx
        self.status_history = status_history[0..idx]
        self.status_history[idx][key] = Time.current
      else
        self.status_history << { key => Time.current }
      end
    end
  end

  def update_order_status
    return unless respond_to?(:orders)

    if self.status == "paid" || status_history.any? { |h| h.key?("paid") }
      update_orders_to("paid", remove: "pending")
    else
      update_orders_to("pending", remove: "paid")
    end
  end

  def update_orders_to(new_status, remove:)
    return unless orders.is_a?(Array)
    
    orders.each do |order_id|
      begin
        order = associated_order_class.find(order_id)
        order.update(status: new_status)
        order.stages ||= []
        order.stages << { new_status => Time.current } unless order.stages.any? { |h| h.key?(new_status) }
        order.stages.delete_if { |h| h.key?(remove) }
        order.save if order.changed? || order.stages_changed?
      rescue ActiveRecord::RecordNotFound
        Rails.logger.warn "Order not found: #{order_id}"
      end
    end
  end

  def associated_order_class
    # Override this in model to return the correct order class
    raise NotImplementedError, "You must define `associated_order_class` in #{self.class.name}"
  end
end
