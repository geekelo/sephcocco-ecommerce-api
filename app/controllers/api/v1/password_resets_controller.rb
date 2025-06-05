class Api::V1::PasswordResetsController < ApplicationController
  def create
    @user = SephcoccoUser.find_by(email: params[:email])
    if @user
      token = @user.generate_password_reset_token!
      UserMailer.password_reset(@user).deliver_now
    end
    render json: { message: 'If your email is in our system, you will receive password reset instructions.' }
  end

  def update
     @user = SephcoccoUser.find_by(reset_password_token: params[:otp])
    if @user.nil? || @user.password_reset_token_expired?
      render json: { alert: 'Password reset link is invalid or has expired.' }
    elsif @user.update(password_params)
      @user.clear_reset_generated_token!
      render json: { notice: 'Your password has been reset successfully.' }
    else
      render json: { alert: 'Failed to reset password. Please try again.' }
    end
  end

  def verify_otp
    @user = SephcoccoUser.find_by(email: params[:email])
    if @user && @user.valid_otp?(params[:otp])
      render json: { notice: 'OTP is valid. You can proceed to reset your password.' }, status: :ok
    else
      render json: { alert: 'Invalid OTP. Please try again.' }, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
