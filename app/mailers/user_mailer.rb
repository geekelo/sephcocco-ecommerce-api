class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @token = @user.reset_password_token
    mail(to: @user.email, subject: "Password Reset Instructions")
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Sephcocco")
  end

  def email_confirmation(user)
    @user = user
    mail(to: @user.email, subject: "Email Confirmation")
  end

  def test_email
    mail(to: "efuelight12@gmail.com", subject: "Test Email")
  end
end
