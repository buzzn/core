CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    config.fog_credentials  = {
      provider:               'AWS',
      aws_access_key_id:      Rails.application.secrets.aws_access_key,
      aws_secret_access_key:  Rails.application.secrets.aws_secret_access_key,
      region:                 Rails.application.secrets.aws_region
    }
    config.fog_directory    = "buzzn-production"
    config.asset_host       = '//cdn.buzzn.net'
    #config.fog_attributes   = { 'Cache-Control' => 'max-age=31556926' }  # 1 year to seconds
  else
    config.storage            = :file
    config.enable_processing  = true
  end
end