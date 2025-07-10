module PaymentModelHelper
  extend ActiveSupport::Concern

  included do
    before_create :set_default_status
    after_save :set_status
    after_save :update_order_status
  end

  private

  def set_default_status
    self.status ||= "pending"
    self.status_history ||= []
    self.status_history << { status: "pending", timestamp: Time.current.iso8601 } unless status_history.any? { |h| h[:status] == "pending" }
  end

  def set_status
    if saved_change_to_status? && status.present?
      # Remove any existing entries with the same status
      self.status_history = status_history.reject { |h| h[:status] == status }
      # Add new status entry
      self.status_history << { status: status, timestamp: Time.current.iso8601 }
    end
  end

  def update_order_status
    return unless respond_to?(:orders)

    if self.status == "paid" || status_history.any? { |h| h[:status] == "paid" }
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
        order.stages << { status: new_status, timestamp: Time.current.iso8601 } unless order.stages.any? { |h| h[:status] == new_status }
        order.stages.delete_if { |h| h[:status] == remove }
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
