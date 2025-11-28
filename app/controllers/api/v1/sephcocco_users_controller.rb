class Api::V1::SephcoccoUsersController < ApplicationController
  before_action :authenticate_user!, except: [ :request_email_confirmation_token, :confirm_email ]
  before_action :check_admin_role, only: [ :index, :create, :update_user_outlets ]
  before_action :set_user, only: [ :show, :update, :destroy, :update_user_outlets, :switch_user_role, :suspend_user, :unsuspend_user, :soft_delete_user ]

  def index
    if current_user.sephcocco_user_role.name == "admin"
      @users = SephcoccoUser.where.not(deleted_at: nil)

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

          if params[:filter][:start_date].present? && params[:filter][:end_date].present?
            @users = @users.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
          elsif params[:filter][:start_date].present?
            @users = @users.where(created_at: params[:filter][:start_date]..Time.current)
          elsif params[:filter][:end_date].present?
            @users = @users.where(created_at: Time.current..params[:filter][:end_date])
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
    subroles = user_params[:subroles]
    
    # Remove outlets from params to avoid trying to set it as an attribute
    user_attributes = user_params.except(:outlets, :subroles)
    
    # Handle outlet updates separately if present
    if outlets_data.present?
      outlets = SephcoccoOutlet.where(name: outlets_data)
      @user.sephcocco_outlets = outlets if outlets.any?
    end

    if subroles.present?
      subroles = SephcoccoUserSubrole.where(name: subroles)
      @user.sephcocco_user_subroles |= subroles if subroles.any?
    end

    # Update other user attributes
    if @user.update(user_attributes)
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "update",
        activity_name: "User",
        activity_description: "User Updated: #{@user.name}",
        outlet: @user.sephcocco_outlets.first.name
      ).call
      render json: { message: "User updated successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # soft delete user
  def soft_delete_user
    return render json: { message: "User already deleted" }, status: :ok if @user.deleted_at.present?
  
    if @user.update(deleted_at: Time.current)
      outlet_name = @user.sephcocco_outlets.first&.name || "N/A"
  
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "update",
        activity_name: "User",
        activity_description: "User deleted: #{@user.name}",
        outlet: outlet_name
      ).call
  
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end  

  def update_user_outlets
    if params[:user][:outlets].present?
      outlets = SephcoccoOutlet.where(name: params[:user][:outlets])
      @user.sephcocco_outlets |= outlets if outlets.any?
    end

    if params[:user][:subroles].present?
      subroles = SephcoccoSubrole.where(name: params[:user][:subroles])
      @user.sephcocco_subroles |= subroles if subroles.any?
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
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "update",
        activity_name: "User",
        activity_description: "User Suspended: #{@user.name}",
        outlet: @user.sephcocco_outlets.first.name
      ).call
      render json: { message: "User suspended successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def unsuspend_user
    if @user.update(suspended: false)
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "update",
        activity_name: "User",
        activity_description: "User Unsuspended: #{@user.name}",
        outlet: @user.sephcocco_outlets.first.name
      ).call
      render json: { message: "User unsuspended successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def get_riders
    riders = SephcoccoUser.where(sephcocco_user_role_id: SephcoccoUserRole.find_by(name: "rider").id)
    render json: riders, each_serializer: SephcoccoUserSerializer
  end

  def check_email_confirmation
    if @user.email_confirmed
      render json: { message: "Email confirmed successfully" }, status: :ok
    else
      render json: { error: "Email not confirmed" }, status: :unprocessable_entity
    end
  end

  def request_email_confirmation_token
    user = SephcoccoUser.find_by(email: params[:email])
    if user.nil?
      render json: { error: "User not found" }, status: :unprocessable_entity
      return
    end
    user.generate_email_confirmation_token!
    UserMailer.email_confirmation(user).deliver_now
    render json: { message: "Email confirmation token requested successfully" }, status: :ok
  end

  def confirm_email
    user = SephcoccoUser.find_by(email: params[:email])
    if user.nil?
      render json: { error: "User not found" }, status: :unprocessable_entity
      return
    end
    if user.email_confirmation_token.nil? || user.email_confirmation_token_expired?
      render json: { error: "Email confirmation token expired" }, status: :unprocessable_entity
      return
    else
      if user.email_confirmation_token === params[:confirmation_token]
        user.confirm_email
        user.clear_email_confirmation_token!
      else
        render json: { error: "Email confirmation token is invalid" }, status: :unprocessable_entity
        return
      end
    end
    if user&.sephcocco_user_role&.name == "admin"
      render json: { message: "Email confirmed successfully", user: SephcoccoUserSerializer.new(user),
      token: JsonWebToken.encode(sub: user.id) }, status: :ok
    else
      render json: { message: "Email confirmed successfully" }, status: :ok
    end
  end

  def get_user_subroles
    subroles = SephcoccoUserSubrole.all
    render json: subroles, each_serializer: SephcoccoUserSubroleSerializer
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
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :address, :phone_number, :whatsapp_number,  :role, outlets: [], subroles: [] )
  end
end
