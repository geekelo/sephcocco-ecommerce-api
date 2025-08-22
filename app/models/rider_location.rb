class RiderLocation < ApplicationRecord
  belongs_to :rider, class_name: 'SephcoccoUser'

  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :timestamp, presence: true

  scope :active, -> { where(active: true) }
  scope :recent, -> { where('timestamp > ?', 5.minutes.ago) }
  scope :by_outlet, ->(outlet_type) { where(outlet_type: outlet_type) }

  # Get the most recent location for a rider
  def self.current_for_rider(rider_id)
    where(rider_id: rider_id, active: true)
      .order(timestamp: :desc)
      .first
  end

  # Get all active rider locations
  def self.all_active
    where(active: true)
      .where('timestamp > ?', 5.minutes.ago)
      .includes(:rider)
  end

  # Check if location is recent (within 5 minutes)
  def recent?
    timestamp > 5.minutes.ago
  end

  # Deactivate old locations
  def self.cleanup_old_locations
    where('timestamp < ?', 5.minutes.ago)
      .update_all(active: false)
  end
end
