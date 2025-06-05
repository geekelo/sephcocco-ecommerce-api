class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @token = @user.reset_password_token
    mail(to: @user.email, subject: 'Password Reset Instructions')
  end
end
