module Api::V1::Concerns::PaymentsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :create, :update, :destroy ]
    before_action :set_payment, only: [ :update, :destroy ]
  end

  def index
    if current_user.sephcocco_user_role.name == "admin"
      payments = payment_class.all
      render json: payments, each_serializer: Lounge::Admin::SephcoccoLoungePaymentSerializer
    else
      payments = current_user.payment_association.all
      render json: payments, each_serializer: Lounge::User::SephcoccoLoungePaymentSerializer
    end
  end

  def create
    actual_payment_params = payment_params.except(:orders_ids)
    if current_user.sephcocco_user_role.name == "admin"
      payment = @customer.payment_association.new(actual_payment_params)
      if payment.save
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "Create",
          activity_name: "Payment",
          activity_description: "Payment Created: #{payment.id}",
          outlet: outlet
        ).call
        if payment_params[:orders_ids].present?
          payment_params[:orders_ids].each do |order_id|
            order = order_class.find(order_id)
            order.update(status: "paid")
            payment.orders << order
          end
        end
        render json: payment, each_serializer: Lounge::Admin::SephcoccoLoungePaymentSerializer, status: :created
      else
        render json: payment.errors, status: :unprocessable_entity
      end
    else
      payment = current_user.payment_association.new(actual_payment_params)
      if payment.save
        AdminNotifications::CreateService.new(
          user: current_user,
          activity_type: "Create",
          activity_name: "Payment",
          activity_description: "Payment Created: #{payment.id}",
          outlet: outlet
        ).call
        if payment_params[:orders_ids].present?
          payment_params[:orders_ids].each do |order_id|
            order = order_class.find(order_id)
            order.update(status: "paid")
            payment.orders << order
          end
        end
        render json: payment, each_serializer: Lounge::Admin::SephcoccoLoungePaymentSerializer, status: :created
      else
          render json: payment.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    if @payment.update(payment_params)
      if current_user.sephcocco_user_role.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "Update",
          activity_name: "Payment",
          activity_description: "Payment Updated: #{@payment.id}",
          outlet: outlet
        ).call
        render json: @payment, each_serializer: Lounge::Admin::SephcoccoLoungePaymentSerializer
      else
        AdminNotifications::CreateService.new(
          user: current_user,
          activity_type: "Update",
          activity_name: "Payment",
          activity_description: "Payment Updated: #{@payment.id}",
          outlet: outlet
        ).call
        render json: @payment, each_serializer: Lounge::User::SephcoccoLoungePaymentSerializer
      end
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @payment.destroy
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "Delete",
          activity_name: "Payment",
          activity_description: "Payment Deleted: #{@payment.id}",
          outlet: outlet
        ).call
      else
        AdminNotifications::CreateService.new(
          user: current_user,
          activity_type: "Delete",
          activity_name: "Payment",
          activity_description: "Payment Deleted: #{@payment.id}",
          outlet: outlet
        ).call
      end
        render json: { message: "Payment deleted successfully" }, status: :ok
    else
        render json: { error: "Failed to delete payment" }, status: :unprocessable_entity
    end
  end

  private

  def set_payment
    if current_user.sephcocco_user_role.name == "admin"
        @payment = payment_class.find(params[:id])
    else
        @payment = current_user.payment_association.find_by(id: params[:id])
    end
  end

  def set_customer
    @customer = SephcoccoUser.find_by(id: params[:sephcocco_user_id])
  end

  def payment_class
      raise NotImplementedError, "You must implement the payment_class method"
  end

  def payment_params
      raise NotImplementedError, "You must implement the payment_params method"
  end
end
