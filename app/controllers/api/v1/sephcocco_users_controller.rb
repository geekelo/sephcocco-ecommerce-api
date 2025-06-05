class Api::V1::SephcoccoUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_role, only: [ :index, :create, :update_user_outlets ]
  before_action :set_user, only: [ :show, :update, :destroy ]

  def update
    if @user.update(user_params)
      render json: { message: "User outlets updated successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_user_outlets
    if params[:user][:outlets].present?
      outlets = SephcoccoOutlet.where(name: params[:user][:outlets])
      @user.sephcocco_outlets |= outlets if outlets.any?
    end

    if @user.save
      render json: { message: "User outlets updated successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_user_outlets
    if params[:user][:outlets].present?
      outlets = SephcoccoOutlet.where(name: params[:user][:outlets])
      @user.sephcocco_outlets |= outlets if outlets.any?
    end

    if @user.save
      render json: { message: "User outlets updated successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def switch_user_role
     if params[:user][:role].present?
      user_role_id = SephcoccoUserRole.find_by(name: params[:user][:role])&.id
      if @user.update(sephcocco_user_role_id: user_role_id)
        render json: { message: "User role updated successfully" }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
     end
  end

  def suspend_user
    if @user.update(suspended: true)
      render json: { message: "User suspended successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def unsuspend_user
    if @user.update(suspended: false)
      render json: { message: "User unsuspended successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = SephcoccoUser.find(params[:id])
  end

  def check_admin_role
    unless current_user&.sephcocco_user_role&.name == "admin"
      render json: { error: "Access denied. Admin role required." }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :address, :phone_number, :whatsapp_number, :role, :outlets)
  end
end
