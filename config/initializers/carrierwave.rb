CarrierWave.configure do |config|

  config.asset_host = Rails.application.secrets.asset_host

  if Rails.env.production? && Rails.env.staging?
    config.storage = :fog
    config.fog_credentials  = {
      provider:               'AWS',
      aws_access_key_id:      Rails.application.secrets.aws_access_key,
      aws_secret_access_key:  Rails.application.secrets.aws_secret_access_key,
      region:                 Rails.application.secrets.aws_region
    }
    config.fog_directory    = Rails.application.secrets.aws_bucket
    #config.fog_attributes   = { 'Cache-Control' => 'max-age=31556926' }  # 1 year to seconds
  else
    config.storage            = :file
    config.enable_processing  = true
  end
end
