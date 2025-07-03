module Api::V1::Concerns::MessageControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def index
    messages = if admin?
      message_class.pluck(:id, product_foreign_key, :created_at, :status)
    else
      current_user.send(user_association_name)
                  .where(status: "open")
                  .pluck(:id, product_foreign_key, :created_at, :status)
    end

    render json: messages, each_serializer: serializer_class
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
end
