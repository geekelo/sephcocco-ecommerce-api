module Api::V1::Concerns::PaymentsControllerHelper
  extend ActiveSupport::Concern

  included do
      before_action :authenticate_user!, only: [:create, :update, :destroy]
      before_action :set_payment, only: [:update, :destroy]
  end
  
  def index
      
      payments = 
      if current_user.sephcocco_user_role.name == 'admin'
        payment_class.all
      else
        current_user.payment_association.all
      end
      render json: payments
  end

  def create
      payment = 
      if current_user.sephcocco_user_role.name == 'admin'
        @customer.payment_association.new(payment_params)
      else
        current_user.payment_association.new(payment_params)
      end
      if payment.save
          render json: payment, status: :created
      else
          render json: payment.errors, status: :unprocessable_entity
      end
  end

  def update
      if @payment.update(payment_params)
          render json: @payment
      else
          render json: @payment.errors, status: :unprocessable_entity
      end
  end

  def destroy
      if @payment.destroy
          render json: { message: 'Payment deleted successfully' }, status: :ok
      else
          render json: { error: 'Failed to delete payment' }, status: :unprocessable_entity
      end
  end

  private

  def set_payment
      if current_user.sephcocco_user_role.name == 'admin'
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
