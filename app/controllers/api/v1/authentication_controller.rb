class Api::V1::AuthenticationController < ApplicationController
  def create
    user = SephcoccoUser.find_by(email: login_params[:email])
    if user
      render json: {
        message: "Login successful",
        user: SephcoccoUserSerializer.new(user),
        token: JsonWebToken.encode(sub: user.id)
        }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:user).permit(:email)
  end
end
