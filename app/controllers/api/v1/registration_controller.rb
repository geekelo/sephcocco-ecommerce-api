class Api::V1::RegistrationController < ApplicationController
  def create
    user_role_id = SephcoccoUserRole.find_by(name: params[:user][:role])&.id unless params[:user][:role].blank?

    if email_already_exists?
      render json: { error: "Email is already registered with us" }, status: :unprocessable_entity
    else
      password = params[:user][:password].presence || "1234567"
      password_confirmation = params[:user][:password_confirmation].presence || "1234567"

      extracted_user_params = user_params.except(:role, :outlets).merge(
        password: password,
        password_confirmation: password_confirmation,

        sephcocco_user_role_id: user_role_id || SephcoccoUserRole.find_by(name: "user")&.id # Default to 'user' role if not specified
      )

      user = SephcoccoUser.new(extracted_user_params)

      if user.save
        if user_params[:outlets].present?
          # Map outlet names to their records
          outlets = SephcoccoOutlet.where(name: user_params[:outlets])

          # Associate only if found
          user.sephcocco_outlets << outlets if outlets&.any?
        end

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
      outlets: []
    )
  end

  def email_already_exists?
    SephcoccoUser.exists?(email: params[:user][:email])
  end
end
