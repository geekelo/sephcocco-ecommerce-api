class Api::V1::RegistrationController < ApplicationController
  def create
     user_role_id = SephcoccoUserRole.find_by(name: params[:user][:role])&.id unless params[:user][:role].blank?

    if email_already_exists?
      render json: { error: "Email is already registered with us" }, status: :unprocessable_entity
    else
      password = params[:user][:password].presence || "123456"
      password_confirmation = params[:user][:password_confirmation].presence || "123456"

      user = SephcoccoUser.new(user_params.merge(
        password: password,
        password_confirmation: password_confirmation,
        profile_image_url: "https:no-image.com",
        sephcocco_user_role_id: user_role_id || SephcoccoUserRole.find_by(name: "user")&.id # Default to 'user' role if not specified
      ))

      if user.save
        render json: { message: "User created successfully" }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :address, :phone_number, :whatsapp_number, :role)
  end

  def email_already_exists?
    SephcoccoUser.exists?(email: params[:user][:email])
  end
end
