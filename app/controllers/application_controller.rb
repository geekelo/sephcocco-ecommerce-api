class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authenticate_user!
    payload = JsonWebToken.decode(auth_token)
    @current_user = SephcoccoUser.find(payload["sub"])
  rescue JWT::DecodeError
    render json: { error: "Invalid auth token" }, status: :unauthorized
  end

  def auth_token
    @auth_token ||= request.headers["Authorization"].to_s.split.last
  end
end
