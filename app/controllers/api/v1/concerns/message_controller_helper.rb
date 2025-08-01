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

  # Admin-specific endpoint to get all user threads
  def user_threads
    return render json: { error: "Admin access required" }, status: :forbidden unless admin?

    # Get all unique users who have message threads
    user_threads = message_class.includes(:sephcocco_user)
                                .group(:sephcocco_user_id)
                                .select('sephcocco_user_id, MAX(created_at) as last_activity, COUNT(*) as message_count')
                                .order('last_activity DESC')

    # Apply status filter
    user_threads = user_threads.where(status: params[:status]) if params[:status].present?

    # Apply pagination
    user_threads = user_threads.page(params[:page]).per(params[:per_page] || 20)

    # Get detailed thread information for each user
    threads_data = user_threads.map do |thread_info|
      user = SephcoccoUser.find(thread_info.sephcocco_user_id)
      latest_message = message_class.where(sephcocco_user_id: thread_info.sephcocco_user_id)
                                   .order(created_at: :desc)
                                   .first

      # Extract last message content from chats JSONB array
      last_message_content = nil
      if latest_message&.chats&.present?
        chats_array = latest_message.chats.is_a?(String) ? JSON.parse(latest_message.chats) : latest_message.chats
        last_message_content = chats_array.last&.dig('content') if chats_array.any?
      end

      {
        user_id: thread_info.sephcocco_user_id,
        user_name: user.name,
        user_email: user.email,
        last_activity: thread_info.last_activity,
        message_count: thread_info.message_count,
        status: latest_message&.status || 'open',
        last_message: last_message_content,
        unread_count: message_class.where(sephcocco_user_id: thread_info.sephcocco_user_id, status: 'unread').count
      }
    end

    render json: {
      user_threads: threads_data,
      meta: {
        total_count: user_threads.total_count,
        total_pages: user_threads.total_pages,
        current_page: user_threads.current_page,
        per_page: user_threads.limit_value
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

    # Broadcast the message update in real-time
    Messaging::BroadcastService.new(message, outlet.name.downcase).call

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
