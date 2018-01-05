CarrierWave.configure do |config|

  config.asset_host = Rails.application.secrets.asset_host

  if Rails.application.secrets.aws_access_key
    config.fog_provider     = 'fog/aws'
    config.fog_credentials  = {
      provider:               'AWS',
      aws_access_key_id:      Rails.application.secrets.aws_access_key,
      aws_secret_access_key:  Rails.application.secrets.aws_secret_access_key,
      region:                 Rails.application.secrets.aws_region
    }
    config.fog_directory    = Rails.application.secrets.aws_bucket
    config.fog_public       = true
  else
    config.storage          = :file
  end

  # fail noisily in development when something goes wrong
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end
