class Api::V1::RegistrationController < ApplicationController
  def create
    if email_already_exists?
      render json: { error: "Email already exists" }, status: :unprocessable_entity
    else
      user = SephcoccoUser.new(user_params)
      if user.save
        render json: { message: "User created successfully" }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:event_user).permit(:email, :password, :password_confirmation)
  end

  def email_already_exists?
    SephcoccoUser.exists?(email: params[:event_user][:email])
  end
end
