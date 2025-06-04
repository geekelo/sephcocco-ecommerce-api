class Api::V1::AuthenticationController < ApplicationController
  def create
    user = SephcoccoUser.find_by(email: login_params[:email])
  
    if user && user.authenticate(params[:user][:password] || "123456")
      if user.suspended?
        return render json: { error: "Your account is suspended. Please contact support." }, status: :forbidden
      end

      user.update(last_login_at: Time.current.strftime("%Y-%m-%d %H:%M:%S"))
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
    params.require(:user).permit(:email, :password)
  end
end
