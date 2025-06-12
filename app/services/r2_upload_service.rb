# app/services/r2_upload_service.rb
class R2UploadService
  def initialize
    @client = Aws::S3::Client.new(
      endpoint: ENV['CLOUDFLARE_R2_ENDPOINT'],
      region: 'auto',
      access_key_id: ENV['CLOUDFLARE_R2_ACCESS_KEY_ID'],
      secret_access_key: ENV['CLOUDFLARE_R2_SECRET_ACCESS_KEY']
    )
  end

  def presign_upload(file_name, content_type, expires_in: 300)
    key = "#{SecureRandom.uuid}-#{file_name}"
    signer = Aws::S3::Presigner.new(client: @client)
    url = signer.presigned_url(
      :put_object,
      bucket: ENV['CLOUDFLARE_R2_BUCKET'],
      key: key,
      content_type: content_type,
      expires_in: expires_in
    )
    public_url = "#{ENV['CLOUDFLARE_R2_BUCKET']}.r2.cloudflarestorage.com/#{key}"
    { presigned_url: url, key:, public_url: "https://#{public_url}" }
  end
end
