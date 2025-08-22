class Api::V1::RiderLocationsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/rider_locations/:rider_id
  def show
    rider_id = params[:id]
    
    # Check if user has permission to view this rider's location
    unless can_view_rider_location?(rider_id)
      render json: { error: "Access denied" }, status: :forbidden
      return
    end
    
    # Get rider location from service
    location_service = RiderLocationService.new(rider_id)
    location = location_service.get_current_location
    
    if location
      render json: {
        rider_id: rider_id,
        location: location,
        online: location_service.rider_online?
      }
    else
      render json: { 
        rider_id: rider_id,
        error: "Location not available",
        online: false
      }, status: :not_found
    end
  end

  # POST /api/v1/rider_locations/update_location
  def update_location
    # Only riders can update their own location
    unless current_user&.sephcocco_user_role&.name == "rider"
      render json: { error: "Only riders can update location" }, status: :forbidden
      return
    end
    
    latitude = params[:latitude]
    longitude = params[:longitude]
    accuracy = params[:accuracy]
    outlet_type = params[:outlet_type]
    
    # Validate coordinates
    unless valid_coordinates?(latitude, longitude)
      render json: { error: "Invalid coordinates" }, status: :unprocessable_entity
      return
    end
    
    # Update location
    location_service = RiderLocationService.new(current_user.id, outlet_type)
    location = location_service.update_location(latitude, longitude, accuracy)
    
    render json: {
      status: "success",
      location: location,
      timestamp: Time.current.iso8601
    }
  end

  # GET /api/v1/rider_locations
  def index
    # Only admins can see all rider locations
    unless current_user&.sephcocco_user_role&.name == "admin"
      render json: { error: "Access denied" }, status: :forbidden
      return
    end
    
    # Get all active rider locations
    locations = RiderLocationService.get_all_active_locations
    
    render json: {
      locations: locations,
      total_count: locations.count
    }
  end

  # POST /api/v1/rider_locations/cleanup
  def cleanup
    # Only admins can trigger manual cleanup
    unless current_user&.sephcocco_user_role&.name == "admin"
      render json: { error: "Access denied" }, status: :forbidden
      return
    end
    
    # Force cleanup (bypass cache check)
    Rails.cache.delete("location_cleanup_all")
    RiderLocation.cleanup_old_locations
    
    render json: {
      status: "success",
      message: "Location cleanup completed",
      timestamp: Time.current.iso8601
    }
  end

  private

  def can_view_rider_location?(rider_id)
    # Admins can view any rider location
    return true if current_user&.sephcocco_user_role&.name == "admin"
    
    # Riders can view their own location
    return true if current_user&.sephcocco_user_role&.name == "rider" && current_user.id == rider_id
    
    # Users can view rider location if they have an active order with that rider
    # This would need to be implemented based on your order tracking logic
    return false
  end

  def valid_coordinates?(latitude, longitude)
    return false unless latitude.present? && longitude.present?
    
    lat = latitude.to_f
    lon = longitude.to_f
    
    # Check if coordinates are within valid ranges
    lat.between?(-90, 90) && lon.between?(-180, 180)
  end
end
