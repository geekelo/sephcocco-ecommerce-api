module Api::V1::Concerns::MessageControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def index
    messages = if admin?
      # Admins can see all messages with filtering options
      messages_query = message_class.includes(:sephcocco_user, product_association_name)
      
      # Apply filters
      messages_query = messages_query.where(status: params[:status]) if params[:status].present?
      messages_query = messages_query.where(product_foreign_key => params[:product_id]) if params[:product_id].present?
      messages_query = messages_query.where(sephcocco_user_id: params[:user_id]) if params[:user_id].present?
      
      # Apply pagination
      messages_query = messages_query.page(params[:page]).per(params[:per_page] || 20)
      
      messages_query
    else
      # Regular users see only their own messages
      current_user.send(user_association_name)
                  .includes(product_association_name)
                  .where(status: params[:status] || "open")
                  .page(params[:page])
                  .per(params[:per_page] || 20)
    end

    render json: {
      messages: ActiveModelSerializers::SerializableResource.new(
        messages,
        each_serializer: serializer_class,
        adapter: :attributes
      ).as_json,
      meta: {
        total_count: messages.total_count,
        total_pages: messages.total_pages,
        current_page: messages.current_page,
        per_page: messages.limit_value
      }
    }
  end

  def get_messages
    # Get messages for a specific conversation/thread
    message_id = params[:message_id]
    product_id = params[:product_id]
    
    if message_id.present?
      # Get messages from a specific thread
      message = message_class.find(message_id)
      authorize_message_access!(message)
      
      render json: {
        message: ActiveModelSerializers::SerializableResource.new(
          message,
          serializer: user_serializer_class,
          adapter: :attributes
        ).as_json
      }
    elsif product_id.present?
      # Get messages for a specific product
      messages = if admin?
        message_class.includes(:sephcocco_user)
                    .where(product_foreign_key => product_id)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(params[:per_page] || 20)
      else
        current_user.send(user_association_name)
                    .where(product_foreign_key => product_id)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(params[:per_page] || 20)
      end
      
      render json: {
        messages: ActiveModelSerializers::SerializableResource.new(
          messages,
          each_serializer: user_serializer_class,
          adapter: :attributes
        ).as_json,
        meta: {
          total_count: messages.total_count,
          total_pages: messages.total_pages,
          current_page: messages.current_page,
          per_page: messages.limit_value
        }
      }
    else
      render json: { error: "Either message_id or product_id is required" }, status: :bad_request
    end
  end

  def show
    message = message_class.find(params[:id])
    render json: message, serializer: user_serializer_class
  end

  def create
    message = Messages::CreateService.new(
      user: current_user,
      params: message_params,
      product_id: message_params[product_param_key],
      message_class: message_class,
      outlet: outlet
    ).call

    # Broadcast the message in real-time
    Messaging::BroadcastService.new(message, outlet.name.downcase).call

    render json: message, serializer: serializer_class, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end

  def update
    message = Messages::UpdateService.new(
      user: current_user,
      message_id: params[:id],
      params: message_params,
      message_class: message_class,
      outlet: outlet
    ).call

    render json: message, serializer: serializer_class
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not authorized or message not found" }, status: :forbidden
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end

  private

  def admin?
    current_user.sephcocco_user_role.name == "admin"
  end

  def message_params
    params.require(:message).permit(:chat, product_param_key)
  end

  # Abstract methods to override in each controller
  def message_class
    raise NotImplementedError, "Define `message_class` in your controller"
  end

  def product_param_key
    raise NotImplementedError, "Define `product_param_key` in your controller"
  end

  def product_foreign_key
    raise NotImplementedError, "Define `product_foreign_key` in your controller"
  end

  def user_association_name
    raise NotImplementedError, "Define `user_association_name` in your controller"
  end

  def serializer_class
    admin? ? admin_serializer_class : user_serializer_class
  end

  def admin_serializer_class
    raise NotImplementedError, "Define `admin_serializer_class` in your controller"
  end

  def user_serializer_class
    raise NotImplementedError, "Define `user_serializer_class` in your controller"
  end

  def product_association_name
    raise NotImplementedError, "Define `product_association_name` in your controller"
  end

  def authorize_message_access!(message)
    unless admin? || message.sephcocco_user_id == current_user.id
      raise ActiveRecord::RecordNotFound, "Not authorized to access this message"
    end
  end
end
