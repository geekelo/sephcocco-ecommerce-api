class Api::V1::SephcoccoUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_role, only: [ :index, :create, :update_user_outlets ]
  before_action :set_user, only: [ :show, :update, :destroy, :update_user_outlets, :switch_user_role, :suspend_user, :unsuspend_user ]

  def index
    if current_user.sephcocco_user_role.name == "admin"
      @users = SephcoccoUser.all
      
      # Calculate summary statistics
      total_admins = SephcoccoUser.joins(:sephcocco_user_role).where(sephcocco_user_roles: { name: "admin" }).count
      total_customers = SephcoccoUser.joins(:sephcocco_user_role).where(sephcocco_user_roles: { name: "user" }).count
      total_riders = SephcoccoUser.joins(:sephcocco_user_role).where(sephcocco_user_roles: { name: "rider" }).count
      total_users = SephcoccoUser.count
      total_active_accounts = SephcoccoUser.where(suspended: false).count
      total_inactive_accounts = SephcoccoUser.where(suspended: true).count
      total_suspended = SephcoccoUser.where(suspended: true).count
      
        # filter by name
        if params[:filter].present?
          if params[:filter][:status].present?
            if params[:filter][:status] == "suspended"
              @users = @users.where(suspended: true)
              else
              @users = @users.where(suspended: false)
            end
          end
          if params[:filter][:search_terms].present?
            @users = @users.where("name ILIKE ? OR email ILIKE ? OR phone_number ILIKE ? OR whatsapp_number ILIKE ?", "%#{params[:filter][:search_terms]}%", "%#{params[:filter][:search_terms]}%", "%#{params[:filter][:search_terms]}%", "%#{params[:filter][:search_terms]}%")
          end
        end

      user_data = {
        users: ActiveModelSerializers::SerializableResource.new(@users, each_serializer: SephcoccoUserSerializer).as_json,
        summary: {
          total_admins: total_admins,
          total_users: total_users,
          total_active_accounts: total_active_accounts,
          total_inactive_accounts: total_inactive_accounts,
          total_suspended: total_suspended,
          total_customers: total_customers
        }
      }
      
      render json: user_data, status: :ok
    else
      render json: { error: "Access denied. Admin role required." }, status: :forbidden
    end
  end

  def update
    # Extract outlets from permitted params
    outlets_data = user_params[:outlets]
    
    # Remove outlets from params to avoid trying to set it as an attribute
    user_attributes = user_params.except(:outlets)
    
    # Handle outlet updates separately if present
    if outlets_data.present?
      outlets = SephcoccoOutlet.where(name: outlets_data)
      @user.sephcocco_outlets = outlets if outlets.any?
    end

    # Update other user attributes
    if @user.update(user_attributes)
      render json: { message: "User updated successfully" }, status: :ok
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

  def get_riders
    riders = SephcoccoUser.where(sephcocco_user_role_id: SephcoccoUserRole.find_by(name: "rider").id)
    render json: riders, each_serializer: SephcoccoUserSerializer
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
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :address, :phone_number, :whatsapp_number, :role, outlets: [])
  end
end
