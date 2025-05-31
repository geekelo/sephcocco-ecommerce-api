class Api::V1::Lounge::SephcoccoLoungeMessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    messages = if current_user.sephcocco_user_role.name == 'admin'
      Lounge::SephcoccoLoungeMessage.pluck(:id, :sephcocco_lounge_product_id, :created_at, :status)
    else
      current_user.send(:sephcocco_lounge_messages).where(status: 'open').pluck(:id, :sephcocco_lounge_product_id, :created_at, :status)
    end

    serializer = admin? ? Lounge::Admin::SephcoccoLoungeMessageSerializer : Lounge::User::SephcoccoLoungeMessageSerializer
    render json: messages, each_serializer: serializer
  end

  def show
    message = Lounge::SephcoccoLoungeMessage.find(params[:id])
    render json: message, serializer: Lounge::User::SephcoccoLoungeMessageSerializer
  end

  def create
    begin
      @message = Lounge::Messages::CreateService.new(user: current_user, params: message_params, product_id: message_params[:sephcocco_lounge_product_id], message_class: Lounge::SephcoccoLoungeMessage).call
      
      if admin?
        render json: @message, serializer: Lounge::Admin::SephcoccoLoungeMessageSerializer, status: :created
      else
        render json: @message, serializer: Lounge::User::SephcoccoLoungeMessageSerializer, status: :created
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: e.record.errors, status: :unprocessable_entity
    end
  end

  def update
    begin
      @message = Lounge::Messages::UpdateService.new(
        user: current_user,
        message_id: params[:id],
        params: message_params
      ).call
      if admin?
        render json: @message, serializer: Lounge::Admin::SephcoccoLoungeMessageSerializer
      else
        render json: @message, serializer: Lounge::User::SephcoccoLoungeMessageSerializer
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Not authorized or message not found' }, status: :forbidden
    rescue ActiveRecord::RecordInvalid => e
      render json: e.record.errors, status: :unprocessable_entity
    end
  end

  private

  def admin?
    current_user.sephcocco_user_role.name == 'admin'
  end

  def message_params
    params.require(:message).permit(:chat, :sephcocco_lounge_product_id)
  end
end
