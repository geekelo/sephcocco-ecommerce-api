# app/controllers/api/v1/concerns/product_manageable.rb
module Api::V1::Concerns::ProductsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :create, :update, :destroy, :switch_visibility, :like, :unlike ]
    before_action :set_product, only: [ :show, :update, :destroy, :switch_visibility, :like, :unlike ]
  end

  def index
    if params[:user_id].present? && params[:user_id] != "null"
      user = SephcoccoUser.find(params[:user_id]) || current_user
    end

    products = case product_class
    when 'Pharmacy::SephcoccoPharmacyProduct'
      product_class.includes(:sephcocco_pharmacy_product_categories).all
    when 'Restaurant::SephcoccoRestaurantProduct'
      product_class.includes(:sephcocco_restaurant_product_categories).all
    when 'Lounge::SephcoccoLoungeProduct'
      product_class.includes(:sephcocco_lounge_product_categories).all
    else
      product_class.all
    end

    # Admin should see all products (visible and hidden), users should only see visible ones
    unless user&.sephcocco_user_role&.name == "admin" || current_user&.sephcocco_user_role&.name == "admin"
      products = products.where(visible: true)
    end

    # Apply filters if they exist
    if params[:filter].present?
      # Apply search_terms filter
      if params[:filter][:search_terms].present?
        products = products.where("#{product_class.table_name}.name ILIKE ?", "%#{params[:filter][:search_terms]}%")
      end

      # Apply visibility or status filter
      if params[:filter][:status].present?
        if params[:filter][:status] == "public"
          products = products.where(visible: true)
        elsif params[:filter][:status] == "private"
          products = products.where(visible: false)
        end
      end

      # Apply category_id filter
      if params[:filter][:category_id].present?
        products = products.joins(category_association_name).where(category_association_name => { id: params[:filter][:category_id] })
      end

      # Apply price_range filter
      if params[:filter][:start_price].present? && params[:filter][:end_price].present?
        products = products.where(price: params[:filter][:start_price]..params[:filter][:end_price])
      end

      # Apply date filters
      if params[:filter][:start_date].present? && params[:filter][:end_date].present?
        # Both dates provided - filter by range
        products = products.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
      elsif params[:filter][:start_date].present?
        # Only start date - filter from start date to now
        products = products.where("created_at >= ?", params[:filter][:start_date])
      elsif params[:filter][:end_date].present?
        # Only end date - filter from beginning to end date
        products = products.where("created_at <= ?", params[:filter][:end_date])
      end

      # Apply search filter
      if params[:filter][:search_terms].present?
        search_term = "%#{params[:filter][:search_terms]}%"
        products = products.where(
          "name ILIKE ? OR short_description ILIKE ? OR long_description ILIKE ? OR barcode ILIKE ?",
          search_term, search_term, search_term, search_term
        )
      end
    end

    # Apply sorting (outside filter block so it always applies)
    if params[:filter].present?
      if params[:filter][:sort_by_likes].present? && params[:filter][:sort_by_likes] == "true"
        products = products.order(likes: :desc)
      elsif params[:filter][:sort_by_stock].present? && params[:filter][:sort_by_stock] == "true"
        products = products.order(amount_in_stock: :desc)
      else
        products = products.order(created_at: :desc)
      end
    else
      # Default sorting when no filters are applied
      products = products.order(created_at: :desc)
    end

    # Apply pagination
    products = products.page(params[:page]).per(params[:per_page] || 20)

    # Use a simpler serializer for the index action
    render json: {
      products: ActiveModelSerializers::SerializableResource.new(
        products,
        each_serializer: product_serializer,
        adapter: :attributes,
        scope: user
      ).as_json,
      meta: {
        total_count: products.total_count,
        total_pages: products.total_pages,
        current_page: products.current_page
      }
    }
  end

  def show
    render json: @product, serializer: product_serializer, scope: current_user
  end

  def create
    @product = product_class.new(product_params.except(:category_ids, :image_url, :other_images))
  
    if @product.save      
      if product_params[:category_ids].present?
        # Assign categories using the association
        @product.send(category_association_name).replace(category_class.where(id: product_params[:category_ids]))
      end

      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "create",
          activity_name: "Product",
          activity_description: "Product Created: #{@product.name}",
          outlet: outlet
        ).call
      end
      render json: @product, serializer: product_serializer, scope: current_user, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params.except(:category_ids))
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Product",
          activity_description: "Product Updated: #{@product.name}",
          outlet: outlet
        ).call
      end
      render json: @product, serializer: product_serializer, scope: current_user, status: :ok
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    if admin?
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "delete",
        activity_name: "Product",
        activity_description: "Product Deleted: #{@product.name}",
        outlet: outlet
      ).call
    end
    render json: { message: "Product deleted successfully" }, status: :ok
  end

  def switch_visibility
    @product.update(visible: !@product.visible)
    if admin?
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "update",
        activity_name: "Product",
        activity_description: "Product Visibility Updated: #{@product.name}",
        outlet: outlet
      ).call
    end
    serializer = product_serializer

   render json: {
     message: "Product visibility updated successfully",
     product: serializer.new(@product, scope: current_user)
   }
  end

  def like
    unless like_class.exists?(product_key => @product.id, user_key => current_user.id)
      @product.increment!(:likes)
      like_class.create(user_key => current_user.id, product_key => @product.id)
      serializer = product_serializer if current_user.sephcocco_user_role.name == "user"
      AdminNotifications::CreateService.new(
        action_type: "product_liked",
        action_id: @product.id,
        user: current_user,
        notification_class: admin_notification_class,
        outlet: outlet
      ).call
      render json: { message: "Product liked successfully", product: serializer.new(@product, scope: current_user) }, status: :created
    else
      render json: { message: "Product already liked" }, status: :unprocessable_entity
    end
  end

  def unlike
    if @product.likes > 0
      if like_class.exists?(product_key => @product.id, user_key => current_user.id)
        like_class.where(product_key => @product.id, user_key => current_user.id).destroy_all
        @product.decrement!(:likes)
        serializer = product_serializer if current_user.sephcocco_user_role.name == "user"
        AdminNotifications::CreateService.new(
          action_type: "product_unliked",
          action_id: @product.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet
        ).call
        render json: { message: "Product unliked successfully", product: serializer.new(@product, scope: current_user) }, status: :ok
      else
        render json: { message: "Product not liked by user" }, status: :unprocessable_entity
      end
    else
      render json: { message: "Product cannot be unliked, no likes to remove" }, status: :unprocessable_entity
    end
  end

  def append_image
    product = set_product
    if product.other_image_keys.nil?
      product.other_image_keys = []
    end
    product.other_image_keys << params[:image_key]
    
    if product.save
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Product",
          activity_description: "Product Image Appended: #{@product.name}",
          outlet: outlet
        ).call
      end
      render json: {
        message: 'Image appended successfully',
        product: product_serializer.new(product, scope: current_user)
      }
    else
      render json: { error: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def set_main_image
    product = find_product
    product.image_key = params[:image_key]
    
    if product.save
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Product",
          activity_description: "Product Main Image Updated: #{@product.name}",
          outlet: outlet
        ).call
      end
      render json: {
        message: 'Main image updated successfully',
        product: product_serializer.new(product, scope: current_user)
      }
    else
      render json: { error: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def upload_image
    product = set_product
    
    if params[:file].present?
      begin
        result = R2UploadService.new.upload_file(params[:file])
        
        if params[:is_main_image]
          product.image_url = result[:key]
        else
          product.other_images ||= []
          product.other_images << result[:key]
        end
        
        if product.save
          render json: {
            message: 'Image uploaded successfully',
            product: product_serializer.new(product, scope: current_user)
          }
        else
          render json: { error: product.errors.full_messages }, status: :unprocessable_entity
        end
      rescue R2UploadService::ConfigurationError => e
        Rails.logger.error("R2 Configuration Error: #{e.message}")
        render json: { error: "Image upload service is not properly configured" }, status: :service_unavailable
      rescue ArgumentError => e
        render json: { error: e.message }, status: :bad_request
      rescue StandardError => e
        Rails.logger.error("Unexpected error during image upload: #{e.message}")
        render json: { error: "Failed to upload image" }, status: :internal_server_error
      end
    else
      render json: { error: 'No file provided' }, status: :bad_request
    end
  end

  private

  def set_product
    @product = product_class.find(params[:id])
  end

  def admin?
    current_user.sephcocco_user_role.name == "admin"
  end

  # The following methods must be overridden in each specific controller:
  def product_class; raise NotImplementedError; end
  def category_class; raise NotImplementedError; end
  def like_class; raise NotImplementedError; end
  def product_key; raise NotImplementedError; end
  def user_key; raise NotImplementedError; end
  def category_association_name; raise NotImplementedError; end
end
