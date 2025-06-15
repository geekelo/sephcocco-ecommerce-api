# app/services/r2_upload_service.rb
class R2UploadService
  def initialize
    @client = Aws::S3::Client.new(
      region: 'auto',
      endpoint: "https://#{ENV['CLOUDFLARE_ACCOUNT_ID']}.r2.cloudflarestorage.com",
      access_key_id: ENV['CLOUDFLARE_R2_ACCESS_KEY_ID'],
      secret_access_key: ENV['CLOUDFLARE_R2_SECRET_ACCESS_KEY']
    )
  end

  def upload_file(file)
    key = generate_unique_key(file.original_filename)
    
    @client.put_object(
      bucket: ENV['CLOUDFLARE_R2_BUCKET'],
      key: key,
      body: file.read,
      content_type: file.content_type
    )

    {
      key: key,
      public_url: "https://#{ENV['CLOUDFLARE_R2_BUCKET']}.r2.cloudflarestorage.com/#{key}"
    }
  end

  private

  def generate_unique_key(original_filename)
    extension = File.extname(original_filename)
    "#{SecureRandom.uuid}#{extension}"
  end
end
