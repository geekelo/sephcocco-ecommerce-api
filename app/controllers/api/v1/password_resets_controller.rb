class Api::V1::PasswordResetsController < ApplicationController

  def create
    @user = SephcoccoUser.find_by(email: params[:email])
    if @user
      token = @user.generate_password_reset_token!
      UserMailer.password_reset(@user).deliver_now
    end
    render json: { notice: 'If your email is in our system, you will receive password reset instructions.' }
  end

  def edit
    @user = SephcoccoUser.find_by(reset_password_token: params[:token])
    if @user.nil? || @user.password_reset_token_expired?
      render json: { alert: 'Password reset link is invalid or has expired.' }
    end
  end

  def update
    @user = SephcoccoUser.find_by(reset_password_token: params[:token])
    if @user.nil? || @user.password_reset_token_expired?
      render json: { alert: 'Password reset link is invalid or has expired.' }
    elsif @user.update(password_params)
      @user.update(reset_password_token: nil, reset_password_sent_at: nil)
      render json: { notice: 'Your password has been reset successfully.' }
    else
      render json: { alert: 'Failed to reset password. Please try again.' }
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
