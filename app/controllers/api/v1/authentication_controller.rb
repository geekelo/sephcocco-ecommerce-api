class Api::V1::AuthenticationController < ApplicationController
  def create
    user = SephcoccoUser.find_by(email: login_params[:email])

    if user && user.authenticate(params[:user][:password] || "1234567")
      if user.deleted_at.present?
        return render json: { error: "Your account is deleted. Please contact support." }, status: :forbidden
      elsif user.email_confirmed?
        return render json: { error: "Your email is not confirmed. Please check your email for confirmation." }, status: :forbidden
      elsif user.email_confirmation_sent_at.present? && user.email_confirmation_sent_at < 2.hours.ago
        return render json: { error: "Your email confirmation link has expired. Please request a new one." }, status: :forbidden
      elsif user.email_confirmation_sent_at.present? && user.email_confirmation_sent_at > 2.hours.ago
        return render json: { error: "Your email confirmation link has expired. Please request a new one." }, status: :forbidden
      elsif user.suspended?
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
