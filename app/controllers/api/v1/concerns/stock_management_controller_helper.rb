# app/controllers/api/v1/concerns/stock_management_controller_helper.rb
module Api::V1::Concerns::StockManagementControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [:index, :create, :show, :update, :destroy, :verify_stock_management]
    before_action :set_stock_management, only: [:show, :update, :destroy]
    before_action :check_admin_role, only: [:index, :create, :update, :destroy, :verify_stock_management]
  end

  def index
    stock_managements = stock_management_class.all
    
    # Apply filters if they exist
    if params[:filter].present?
      # Apply status filter
      if params[:filter][:status].present?
        stock_managements = stock_managements.where(status: params[:filter][:status])
      end
      
      # Apply vendor filter
      if params[:filter][:vendor_id].present?
        stock_managements = stock_managements.where(:"sephcocco_#{outlet}_vendor_id" => params[:filter][:vendor_id])
      end
      
      # Apply department filter
      if params[:filter][:department_id].present?
        stock_managements = stock_managements.where(:"sephcocco_#{outlet}_department_id" => params[:filter][:department_id])
      end
      
      # Apply date filter
      if params[:filter][:start_date].present? && params[:filter][:end_date].present?
        stock_managements = stock_managements.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
      elsif params[:filter][:start_date].present?
        stock_managements = stock_managements.where('created_at >= ?', params[:filter][:start_date])
      elsif params[:filter][:end_date].present?
        stock_managements = stock_managements.where('created_at <= ?', params[:filter][:end_date])
      end
      
      # Apply search filter
      if params[:filter][:search_terms].present?
        search_term = "%#{params[:filter][:search_terms]}%"
        stock_managements = stock_managements.joins(:"sephcocco_#{outlet}_product")
                                            .left_joins(:"sephcocco_#{outlet}_vendor")
                                            .where(
                                              "invoice_number ILIKE ? OR sephcocco_#{outlet}_vendors.name ILIKE ? OR sephcocco_#{outlet}_products.name ILIKE ? OR stock::text ILIKE ? OR price::text ILIKE ?",
                                              search_term, search_term, search_term, search_term, search_term
                                            )
      end
    end

    # Sort by date
    stock_managements = stock_managements.order(created_at: :desc)

    # Apply pagination
    stock_managements = stock_managements.page(params[:page]).per(params[:per_page] || 20)

    render json: {
      stock_managements: ActiveModelSerializers::SerializableResource.new(
        stock_managements, 
        each_serializer: stock_management_serializer
      ).as_json,
      meta: {
        total_count: stock_managements.total_count,
        total_pages: stock_managements.total_pages,
        current_page: stock_managements.current_page,
        per_page: stock_managements.limit_value
      }
    }
  end

  def show
    render json: @stock_management, serializer: stock_management_serializer
  end

  def create
    # Get the product first
    product_id = stock_management_params[:"sephcocco_#{outlet}_product_id"]
    if product_id.blank?
      render json: { 
        error: "Product ID is required", 
        expected_field: "sephcocco_#{outlet}_product_id",
        received_params: stock_management_params.keys
      }, status: :unprocessable_entity
      return
    end
    
    begin
      product = product_class.find(product_id)
    rescue ActiveRecord::RecordNotFound
      render json: { 
        error: "Product not found", 
        product_id: product_id,
        product_class: product_class.name
      }, status: :not_found
      return
    end
    old_stock = product.amount_in_stock
    old_price = product.price

    # Prepare the parameters with calculated values
    params_hash = stock_management_params.to_h
    params_hash[:stock] ||= {}
    params_hash[:price] ||= {}
    
    # Validate required fields
    if params_hash[:stock][:add_stock].blank?
      render json: { error: "add_stock is required in stock object" }, status: :unprocessable_entity
      return
    end
    
    if params_hash[:price][:cost_price].blank? || params_hash[:price][:profit_markup].blank?
      render json: { error: "cost_price and profit_markup are required in price object" }, status: :unprocessable_entity
      return
    end
    
    params_hash[:stock][:old_stock] = old_stock
    params_hash[:price][:old_price] = old_price
    params_hash[:stock][:new_stock] = old_stock + params_hash[:stock][:add_stock].to_i
    params_hash[:price][:new_price] = params_hash[:price][:cost_price].to_f + params_hash[:price][:profit_markup].to_f

    @stock_management = stock_management_class.new(params_hash)
    
    if @stock_management.save

      # Create admin activity
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "create",
        activity_name: "Stock Management",
        activity_description: "Stock Management Created: #{@stock_management.invoice_number}",
        outlet: outlet
      ).call
      
      render json: @stock_management, serializer: stock_management_serializer, status: :created
    else
      render json: { errors: @stock_management.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @stock_management.update(stock_management_params)

      if @stock_management.status == "approved"
        # update the product stock and price
        product = product_class.find(@stock_management.send(:"sephcocco_#{outlet}_product_id"))
        
        # Get the add_stock amount to add to current stock
        add_stock = @stock_management.stock&.dig('add_stock')
        new_price = @stock_management.price&.dig('new_price')
        
    
        if add_stock.present? && add_stock.to_i > 0
          # Add the stock to current stock instead of replacing it
          updated_stock = product.amount_in_stock + add_stock.to_i
          product.update!(amount_in_stock: updated_stock)
        else
          Rails.logger.error "Invalid add_stock value: #{add_stock} for stock management #{@stock_management.id}"
        end
        
        if new_price.present? && new_price.to_f > 0
          product.update!(price: new_price.to_f)
        else
          Rails.logger.error "Invalid new_price value: #{new_price} for stock management #{@stock_management.id}"
        end
      end
      # Create admin activity
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "update",
        activity_name: "Stock Management",
        activity_description: @stock_management.status == "approved" ? "Stock Management Approved: #{@stock_management.invoice_number}" : "Stock Management Updated: #{@stock_management.invoice_number}",
        outlet: outlet
      ).call
      
      render json: @stock_management, serializer: stock_management_serializer
    else
      render json: { errors: @stock_management.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @stock_management.destroy
      # Create admin activity
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "delete",
        activity_name: "Stock Management",
        activity_description: "Stock Management Deleted: #{@stock_management.invoice_number}",
        outlet: outlet
      ).call
      
      render json: { message: "Stock management deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete stock management" }, status: :unprocessable_entity
    end
  end


  def verify_stock_management
    stock_management_ids = params[:stock_management_ids]
  
    ActiveRecord::Base.transaction do
      stock_management_ids.each do |stock_management_id|
        stock_management = stock_management_class.find(stock_management_id)
  
        if params[:status] == "declined"
          stock_management.update!(status: "declined")
  
          description = "Stock Management Declined: #{stock_management.invoice_number}"
  
        elsif params[:status] == "approved"
          product = product_class.find(
            stock_management.send(:"sephcocco_#{outlet}_product_id")
          )
  
          # Handle both hash and array formats for stock
          raw_stock = stock_management.stock
          add_stock = case raw_stock
                      when Array
                        raw_stock.sum { |entry| entry['add_stock'].to_i }
                      when Hash
                        raw_stock&.dig("add_stock")
                      else
                        nil
                      end
          new_price = stock_management.price&.dig("new_price")
  
          if add_stock.present? && add_stock.to_i > 0
            updated_stock = product.amount_in_stock + add_stock.to_i
            product.update!(amount_in_stock: updated_stock)
          end
  
          # (Optional) update price if needed
          if new_price.present?
            product.update!(price: new_price)
          end
  
          stock_management.update!(status: "approved")
  
          description = "Stock Management Approved: #{stock_management.invoice_number}"
        else
          raise ActiveRecord::RecordInvalid.new(stock_management)
        end
  
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Stock Management",
          activity_description: description,
          outlet: outlet
        ).call
      end
    end
  
    render json: { message: "Stock management records updated successfully" }, status: :ok
  
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end  
  

  private

  def set_stock_management
    @stock_management = stock_management_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Stock management not found" }, status: :not_found
  end

  def check_admin_role
    unless admin?
      render json: { error: "Access denied. Admin role required." }, status: :forbidden
    end
  end

  def admin?
    current_user&.sephcocco_user_role&.name == "admin"
  end

  def stock_management_params
    params.require(stock_management_param_key).permit(
      :"sephcocco_#{outlet}_product_id",
      :"sephcocco_#{outlet}_vendor_id",
      :"sephcocco_#{outlet}_department_id",
      :invoice_number,
      :status,
      stock: {},
      price: {}
    )
  end

  def stock_management_param_key
    "sephcocco_#{outlet}_stock_management"
  end

  def stock_management_class
    raise NotImplementedError, "You must implement the stock_management_class method"
  end

  def stock_management_serializer
    raise NotImplementedError, "You must implement the stock_management_serializer method"
  end

  def outlet
    raise NotImplementedError, "You must implement the outlet method"
  end
end
