# frozen_string_literal: true

# Wrapper object so ActiveModelSerializers can serialize grouped orders.
# AMS expects `object.class.model_name` to exist; Arrays don't have it.
class GroupedOrdersCollection
  include ActiveModel::Model

  attr_accessor :orders

  def initialize(orders:)
    @orders = orders
  end
end

