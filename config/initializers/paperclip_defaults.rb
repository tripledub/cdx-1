Paperclip::Attachment.default_options.update(
  url: '/system/:class/:attachment/:id_partition/:style/:hash.:extension',
  hash_secret: Rails.application.secrets.secret_key_base
)

if ENV['PAPERCLIP_S3_BUCKET']
  Rails.application.config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket: ENV.fetch('PAPERCLIP_S3_BUCKET'),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      s3_region: ENV.fetch('AWS_REGION')
    }
  }
end
