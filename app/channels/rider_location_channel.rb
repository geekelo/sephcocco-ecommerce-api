class RiderLocationChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "RiderLocationChannel#subscribed called"
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "User role: #{current_user&.sephcocco_user_role&.name}"
    Rails.logger.info "Outlet type param: #{params[:outlet_type]}"
    
    if current_user
      if current_user.sephcocco_user_role.name == "rider"
        # Rider subscribes to their own location channel
        rider_channel = "rider_location_#{current_user.id}"
        Rails.logger.info "Rider subscribing to channel: #{rider_channel}"
        stream_from rider_channel
        
        # Also subscribe to general rider location channel for admin
        admin_channel = "rider_locations_admin"
        Rails.logger.info "Rider subscribing to admin channel: #{admin_channel}"
        stream_from admin_channel
        
        # Send connection confirmation for async adapter
        transmit({
          type: 'connection_confirmed',
          rider_id: current_user.id,
          message: 'Location tracking channel connected',
          timestamp: Time.current.iso8601
        })
        
      elsif current_user.sephcocco_user_role.name == "admin"
        # Admin subscribes to all rider locations
        admin_channel = "rider_locations_admin"
        Rails.logger.info "Admin subscribing to channel: #{admin_channel}"
        stream_from admin_channel
        
        # Send current active locations immediately for async adapter
        send_current_locations
        
      else
        # Regular users subscribe to specific rider location for their orders
        rider_id = params[:rider_id]
        if rider_id
          user_rider_channel = "rider_location_#{rider_id}"
          Rails.logger.info "User subscribing to rider channel: #{user_rider_channel}"
          stream_from user_rider_channel
        end
      end
    else
      Rails.logger.warn "No current_user found in RiderLocationChannel#subscribed"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    Rails.logger.info "📍 Received rider location data: #{data.inspect}"
    
    # Handle ping for connection testing
    if data['type'] == 'ping'
      Rails.logger.info "🏓 Received ping, sending pong response"
      ActionCable.server.broadcast(
        "rider_location_#{current_user&.id || 'unknown'}",
        {
          type: 'pong',
          timestamp: data['timestamp'],
          message: 'Rider location connection is working!'
        }
      )
      return
    end
    
    # Handle location update from rider (real-time updates only)
    if data['action'] == 'update_location'
      update_rider_location(data)
      return
    end
    
    # Handle location request from user/admin (real-time requests)
    if data['action'] == 'request_location'
      request_rider_location(data)
      return
    end
  end

  private

  # Send current active locations to admin (optimized for async adapter)
  def send_current_locations
    locations = RiderLocationService.get_all_active_locations
    
    transmit({
      type: 'current_locations',
      locations: locations,
      total_count: locations.count,
      timestamp: Time.current.iso8601
    })
  end

  def update_rider_location(data)
    return unless current_user&.sephcocco_user_role&.name == "rider"
    
    latitude = data['latitude']
    longitude = data['longitude']
    accuracy = data['accuracy']
    outlet_type = data['outlet_type']
    
    Rails.logger.info "📍 Rider #{current_user.id} updating location: #{latitude}, #{longitude}"
    
    # Use the service to update location in database
    location_service = RiderLocationService.new(current_user.id, outlet_type)
    location_data = location_service.update_location(latitude, longitude, accuracy)
    
    # Broadcast to admin channel
    ActionCable.server.broadcast(
      "rider_locations_admin",
      {
        type: 'rider_location_updated',
        rider_id: current_user.id,
        rider_name: current_user.name,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        timestamp: Time.current.iso8601,
        outlet_type: data['outlet_type']
      }
    )
    
    # Broadcast to rider's own channel for confirmation
    ActionCable.server.broadcast(
      "rider_location_#{current_user.id}",
      {
        type: 'location_update_confirmation',
        status: 'success',
        timestamp: Time.current.iso8601
      }
    )
  end

  def request_rider_location(data)
    rider_id = data['rider_id']
    outlet_type = data['outlet_type']
    
    Rails.logger.info "📍 Requesting location for rider: #{rider_id}"
    
    # Get location from database using service
    location_service = RiderLocationService.new(rider_id, outlet_type)
    location_data = location_service.get_current_location
    
    if location_data
      Rails.logger.info "📍 Found location for rider #{rider_id}: #{location_data}"
      
      # Send location to requester
      ActionCable.server.broadcast(
        "rider_location_#{rider_id}",
        {
          type: 'rider_location_response',
          rider_id: rider_id,
          location: location_data,
          requested_at: Time.current.iso8601
        }
      )
    else
      Rails.logger.info "📍 No location found for rider #{rider_id}"
      
      # Send not found response
      ActionCable.server.broadcast(
        "rider_location_#{rider_id}",
        {
          type: 'rider_location_response',
          rider_id: rider_id,
          error: 'Location not available',
          requested_at: Time.current.iso8601
        }
      )
    end
  end
end
