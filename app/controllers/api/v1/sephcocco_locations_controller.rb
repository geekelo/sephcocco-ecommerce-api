class Api::V1::SephcoccoLocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_location, only: [:show, :update, :destroy]

  def index
    @locations = SephcoccoLocation.all

    # Apply filters if they exist
    if params[:filter].present?
      if params[:filter][:search_terms].present?
        @locations = @locations.where("location ILIKE ?", "location_price ILIKE ?", "%#{params[:filter][:search_terms]}%", "%#{params[:filter][:search_terms]}%")
      end
      if params[:filter][:start_date].present? && params[:filter][:end_date].present?
        @locations = @locations.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
      elsif params[:filter][:start_date].present?
        @locations = @locations.where(created_at: params[:filter][:start_date]..Time.current)
      elsif params[:filter][:end_date].present?
        @locations = @locations.where(created_at: Time.current..params[:filter][:end_date])
      end
    end

    @locations = @locations.order(created_at: :desc)
    @locations = @locations.page(params[:page]).per(params[:per_page] || 20)

    render json: {
      locations: ActiveModelSerializers::SerializableResource.new(@locations, each_serializer: SephcoccoLocationSerializer).as_json,
      meta: {
        total_count: @locations.total_count,
        total_pages: @locations.total_pages,
        current_page: @locations.current_page
      }
    }
  end

  def create
    @location = SephcoccoLocation.new(location_params)
    if @location.save
      render json: @location, serializer: SephcoccoLocationSerializer, status: :created
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  def update
    @location.update(location_params)
    if @location.save
      render json: @location, serializer: SephcoccoLocationSerializer, status: :ok
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    render json: { message: "Location deleted successfully" }, status: :ok
  end

  private

  def set_location
    @location = SephcoccoLocation.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:location, :logistics_price)
  end
end
