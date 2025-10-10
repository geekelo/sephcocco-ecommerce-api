class Api::V1::SephcoccoLocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_location, only: [:show, :update, :destroy]

  def index
    @locations = SephcoccoLocation.all
    render json: @locations
  end

  def create
    @location = SephcoccoLocation.new(location_params)
    if @location.save
      render json: @location, status: :created
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  def update
    @location = SephcoccoLocation.find(params[:id])
    @location.update(location_params)
    if @location.save
      render json: @location, status: :ok
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @location = SephcoccoLocation.find(params[:id])
    @location.destroy
  end

  private

  def set_location
    @location = SephcoccoLocation.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:location, :logistics_price)
  end
end
