module Api::V1::Concerns::PaymentsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :create, :update, :destroy ]
    before_action :set_payment, only: [ :update, :destroy ]
    before_action :set_customer, only: [ :create ]
  end

  def index
    if current_user.sephcocco_user_role.name == "admin"
      payments = payment_class.all
      render json: payments, each_serializer: payment_serializer
    else
      payments = current_user.send(payment_association).all
      render json: payments, each_serializer: payment_serializer
    end
  end

  def create
    order_ids = payment_params[:orders_ids]
    actual_payment_params = payment_params.except(:orders_ids).merge(orders: order_ids || [])
    if current_user.sephcocco_user_role.name == "admin"
      payment = @customer&.send(payment_association)&.new(actual_payment_params) || payment_class.new(actual_payment_params)
      if payment.save
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "Create",
          activity_name: "Payment",
          activity_description: "Payment Created: #{payment.id}",
          outlet: outlet
        ).call
        if order_ids.present?
          order_ids.each do |order_id|
            order = order_class.find(order_id)
            order.update(status: "paid")
            payment.orders << order
          end
        end
        render json: payment, each_serializer: payment_serializer, status: :created
      else
        render json: payment.errors, status: :unprocessable_entity
      end
    else
      payment = current_user.send(payment_association).new(actual_payment_params)
      if payment.save
        AdminNotifications::CreateService.new(
          user: current_user,
          activity_type: "Create",
          activity_name: "Payment",
          activity_description: "Payment Created: #{payment.id}",
          outlet: outlet
        ).call
        if order_ids.present?
          order_ids.each do |order_id|
            order = order_class.find(order_id)
            order.update(status: "paid")
            payment.orders << order
          end
        end
        render json: payment, each_serializer: payment_serializer, status: :created
      else
          render json: payment.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    status = payment_params[:status] if payment_params[:status].present?
    if @payment.update(payment_params)
      @payment.orders.each do |order|
        if status == "confirmed"
          order.update(status: "payment confirmed")
          @payment.sephcocco_user.update(payment_ref: @payment.sephcocco_user.payment_ref.next)
        elsif status == "cancelled"
          order.update(status: "payment cancelled")
        elsif status == "pending"
          order.update(status: "payment pending")
        elsif status == "declined"
          order.update(status: "payment declined")
        end
      end
      
      if current_user.sephcocco_user_role.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "Update",
          activity_name: "Payment",
          activity_description: "Payment #{status}ed: #{@payment.id}",
          outlet: outlet
        ).call
        render json: @payment, each_serializer: payment_serializer
      else
        AdminNotifications::CreateService.new(
          user: current_user,
          activity_type: "Update",
          activity_name: "Payment",
          activity_description: "Payment Cancelled: #{@payment.id}",
          outlet: outlet
        ).call
        render json: @payment, each_serializer: payment_serializer
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
        @payment = current_user.send(payment_association).find_by(id: params[:id])
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
