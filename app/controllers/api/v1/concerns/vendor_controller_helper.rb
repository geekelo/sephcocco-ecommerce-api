module Api::V1::Concerns::VendorControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :set_vendor, only: [:show, :update, :destroy]
  end

  # GET /vendors
  def index
    vendors = vendor_class.all.order(created_at: :desc)
    
    render json: vendors, each_serializer: vendor_serializer, status: :ok
  end

  # GET /vendors/:id
  def show
    render json: @vendor, serializer: vendor_serializer, status: :ok
  end

  # POST /vendors
  def create
    vendor = vendor_class.new(vendor_params)

    if vendor.save
      render json: vendor, serializer: vendor_serializer, status: :created
    else
      render json: { errors: vendor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vendors/:id
  def update
    if @vendor.update(vendor_params)
      render json: @vendor, serializer: vendor_serializer, status: :ok
    else
      render json: { errors: @vendor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /vendors/:id
  def destroy
    @vendor.destroy
    render json: { message: "Vendor deleted successfully" }, status: :ok
  rescue => e
    render json: { error: "Failed to delete vendor: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_vendor
    @vendor = vendor_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Vendor not found" }, status: :not_found
  end

  def vendor_params
    params.require(vendor_param_key).permit(
      :name, 
      :email, 
      :phone, 
      :address, 
      :city, 
      :state, 
      :bank_details, 
      :country
    )
  end

  # To be implemented by including controllers
  def vendor_class
    raise NotImplementedError, "You must implement the vendor_class method"
  end

  def vendor_param_key
    raise NotImplementedError, "You must implement the vendor_param_key method"
  end

  def vendor_serializer
    raise NotImplementedError, "You must implement the vendor_serializer method"
  end
end
