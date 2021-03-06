require 'carrierwave'
require 'carrierwave/orm/activerecord'

CarrierWave.root = '.'

CarrierWave.configure do |config|

  # fail noisily in development when something goes wrong
  config.ignore_integrity_errors  = false
  config.ignore_processing_errors = false
  config.ignore_download_errors   = false

  # AWS
  if Import.global?('config.aws_access_key')
    config.fog_provider     = 'fog/aws'
    config.fog_credentials  = {
      provider:               'AWS',
      aws_access_key_id:      Import.global('config.aws_access_key'),
      aws_secret_access_key:  Import.global('config.aws_secret_key'),
      region:                 Import.global('config.aws_region')
    }
    config.fog_directory    = Import.global('config.aws_bucket')
    config.asset_host       = Import.global('config.asset_host')

  # use local filesystem (usually in development and test)
  else
    config.fog_provider     = 'fog/local'
    config.fog_credentials  = {
      provider:   'Local',
      local_root: 'public',
      endpoint:   Import.global('config.hostname')
    }
    config.fog_directory    = '' # when left nil, we get an exeption.
    config.asset_host       = nil
  end
end
