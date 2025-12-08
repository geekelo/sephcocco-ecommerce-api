class Api::V1::RegistrationController < ApplicationController
  def create
    user_role_id = SephcoccoUserRole.find_by(name: params[:user][:role])&.id unless params[:user][:role].blank?

    if email_already_exists?
      render json: { error: "Email is already registered with us" }, status: :unprocessable_entity
    else
      password = params[:user][:password].presence || "1234567"
      password_confirmation = params[:user][:password_confirmation].presence || "1234567"

      extracted_user_params = user_params.except(:role, :outlets, :subroles).merge(
        password: password,
        password_confirmation: password_confirmation,

        sephcocco_user_role_id: user_role_id || SephcoccoUserRole.find_by(name: "user")&.id # Default to 'user' role if not specified
      )


      existing_user = SephcoccoUser.find_by(email: params[:user][:email])
      if existing_user&.deleted_at.present?
        restore_user(existing_user)
        existing_user.update(extracted_user_params.merge(email_confirmed: true, suspended: false))
        user = existing_user
      else
        user = SephcoccoUser.new(extracted_user_params)
      end

      if user.save
        if user_params[:outlets].present?
          # Map outlet names to their records
          outlets = SephcoccoOutlet.where(name: user_params[:outlets])

          # Associate only if found
          user.sephcocco_outlets << outlets if outlets&.any?
        end

        if user_params[:subroles].present?
          subroles = SephcoccoUserSubrole.where(name: user_params[:subroles])
          user.sephcocco_user_subroles << subroles if subroles&.any?
        end

        if user.sephcocco_user_role.name == "admin" 
          # Create admin activities for all outlets when admin is created
          ["pharmacy", "restaurant", "lounge"].each do |outlet_name|
            AdminActivities::CreateService.new(
              user: user,
              activity_type: "create",
              activity_name: "User",
              activity_description: "New Admin Created: #{user.name}",
              outlet: outlet_name
            ).call
          end
        elsif user.sephcocco_user_role.name == "rider"
          # Create admin activities for all outlets when rider is created
          ["pharmacy", "restaurant", "lounge"].each do |outlet_name|
            AdminActivities::CreateService.new(
              user: user,
              activity_type: "create",
              activity_name: "User",
              activity_description: "New Rider Created: #{user.name}",
              outlet: outlet_name
            ).call
          end
        else
          # Create admin notifications for all outlets when regular user is created
          ["pharmacy", "restaurant", "lounge"].each do |outlet_name|
            notification_class = case outlet_name
            when "pharmacy"
              Pharmacy::SephcoccoPharmacyAdminNotification
            when "restaurant"
              Restaurant::SephcoccoRestaurantAdminNotification
            when "lounge"
              Lounge::SephcoccoLoungeAdminNotification
            end
            
            AdminNotifications::CreateService.new(
              action_type: "New User",
              action_id: user.id,
              user: user,
              notification_class: notification_class,
              outlet: outlet_name
            ).call
          end
        end

        # send welcome email to user with email confirmation
        user.generate_email_confirmation_token!
        UserMailer.welcome_email(user).deliver_now
        UserMailer.email_confirmation(user).deliver_now

        render json: { message: "User created successfully" }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :name,
      :address,
      :phone_number,
      :whatsapp_number,
      :role,
      outlets: [],
      subroles: []
    )
  end

  def email_already_exists?
    existing_user = SephcoccoUser.find_by(email: params[:user][:email])
    existing_user.present? && existing_user.deleted_at.blank?
  end

  def restore_user(user)
    user.update(deleted_at: nil)
  end
end
