class Restaurant::SephcoccoRestaurantShipping < ApplicationRecord
  belongs_to :sephcocco_restaurant_order
  belongs_to :rider, class_name: "SephcoccoUser", optional: true

  validates :tracking_number, presence: true
  validates :status, presence: true
  validates :sephcocco_restaurant_order_id, presence: true

  # Status options
  enum status: {
    pending: 'pending',
    assigned: 'assigned',
    in_transit: 'in_transit',
    delivered: 'delivered',
    cancelled: 'cancelled'
  }

  scope :active, -> { where.not(status: 'cancelled') }
  scope :dispatching, -> { where(dispatching: true) }
  scope :by_rider, ->(rider) { where(rider: rider) }
end 