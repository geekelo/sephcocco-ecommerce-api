class ApplicationRecord < ActiveRecord::Base
  attr_reader :current_user
  self.abstract_class = true

  private

  def authenticate_user!
    payload = JsonWebToken.decode(auth_token)
    @current_user = SephcoccoUser.find(payload["sub"])
  rescue JWT::DecodeError
    render json: { error: "Invalid Auth Token" }, status: :unauthorized
  end

  def auth_token
    @auth_token ||= request.headers.fetch("Authorization", "").split.last
  end
end
