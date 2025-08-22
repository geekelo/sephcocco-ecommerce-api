class RiderLocationService
  def initialize(rider_id, outlet_type = nil)
    @rider_id = rider_id
    @outlet_type = outlet_type
  end

  # Get current location of a rider
  def get_current_location
    # Trigger cleanup of old locations when requesting current location
    cleanup_old_locations
    
    location = RiderLocation.current_for_rider(@rider_id)
    return nil unless location&.recent?
    
    {
      rider_id: @rider_id,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      timestamp: location.timestamp.iso8601,
      outlet_type: location.outlet_type
    }
  end

  # Update rider location
  def update_location(latitude, longitude, accuracy = nil)
    # Deactivate old locations for this rider
    RiderLocation.where(rider_id: @rider_id, active: true)
                 .update_all(active: false)
    
    # Create new location record
    location = RiderLocation.create!(
      rider_id: @rider_id,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      outlet_type: @outlet_type,
      timestamp: Time.current,
      active: true
    )
    
    location_data = {
      rider_id: @rider_id,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      timestamp: location.timestamp.iso8601,
      outlet_type: location.outlet_type
    }
    
    # Broadcast to relevant channels
    broadcast_location_update(location_data)
    
    location_data
  end

  # Get all active rider locations
  def self.get_all_active_locations
    # Trigger cleanup before getting all locations
    cleanup_old_locations
    
    RiderLocation.all_active.map do |location|
      {
        rider_id: location.rider_id,
        rider_name: location.rider.name,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        timestamp: location.timestamp.iso8601,
        outlet_type: location.outlet_type
      }
    end
  end

  # Class method for cleanup
  def self.cleanup_old_locations
    # Use a simple cache key to avoid frequent cleanups
    cleanup_key = "location_cleanup_all"
    
    if Rails.cache.read(cleanup_key).nil?
      Rails.logger.info "🧹 Cleaning up old rider locations (all)"
      RiderLocation.cleanup_old_locations
      # Set cleanup flag for 10 minutes to avoid frequent cleanups
      Rails.cache.write(cleanup_key, true, expires_in: 10.minutes)
    end
  end

  # Check if rider is online/active
  def rider_online?
    location = RiderLocation.current_for_rider(@rider_id)
    location&.recent? || false
  end

  private

  # Cleanup old location records (triggered on location requests)
  def cleanup_old_locations
    # Only cleanup occasionally to avoid performance impact
    # Use a simple counter based on rider_id to stagger cleanup
    cleanup_key = "location_cleanup_#{@rider_id % 10}"
    
    if Rails.cache.read(cleanup_key).nil?
      Rails.logger.info "🧹 Cleaning up old rider locations"
      RiderLocation.cleanup_old_locations
      # Set cleanup flag for 5 minutes to avoid frequent cleanups
      Rails.cache.write(cleanup_key, true, expires_in: 5.minutes)
    end
  end

  # Calculate distance between two coordinates (Haversine formula)
  def self.calculate_distance(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI / 180
    earth_radius = 6371 # Earth's radius in kilometers
    
    lat1_rad = lat1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg
    
    delta_lat_rad = (lat2 - lat1) * rad_per_deg
    delta_lon_rad = (lon2 - lon1) * rad_per_deg
    
    a = Math.sin(delta_lat_rad / 2) ** 2 +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lon_rad / 2) ** 2
    
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    earth_radius * c
  end

  # Find nearest rider to a location
  def self.find_nearest_rider(latitude, longitude, outlet_type = nil)
    # This would need to be implemented based on your Redis setup
    # For now, we'll return nil
    nil
  end

  private

  def broadcast_location_update(location_data)
    # Broadcast to admin channel
    ActionCable.server.broadcast(
      "rider_locations_admin",
      {
        type: 'rider_location_updated',
        rider_id: @rider_id,
        latitude: location_data['latitude'],
        longitude: location_data['longitude'],
        accuracy: location_data['accuracy'],
        timestamp: location_data['timestamp'],
        outlet_type: location_data['outlet_type']
      }
    )
    
    # Broadcast to rider's own channel
    ActionCable.server.broadcast(
      "rider_location_#{@rider_id}",
      {
        type: 'location_update_confirmation',
        status: 'success',
        timestamp: location_data['timestamp']
      }
    )
  end
end
