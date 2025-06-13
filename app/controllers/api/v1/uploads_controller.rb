# app/controllers/api/v1/uploads_controller.rb
class Api::V1::UploadsController < ApplicationController
  before_action :authenticate_user!

  def presign
    data = R2UploadService.new.presign_upload(params[:file_name], params[:content_type])
    render json: data
  rescue => e
    render json: { error: e.message }, status: 500
  end

  def presign_multiple
    files = params.require(:files) # expects an array of { file_name, content_type }
    data = files.map do |file|
      R2UploadService.new.presign_upload(file[:file_name], file[:content_type])
    end
    render json: data
  rescue ActionController::ParameterMissing
    render json: { error: "Missing 'files' array" }, status: :bad_request
  end

  def save
    current_user.files.create!(
      object_key: params[:key],
      file_url: params[:public_url]
    )
    render json: { success: true }
  rescue => e
    render json: { error: e.message }, status: 500
  end
end
