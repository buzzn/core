require 'carrierwave'
require 'carrierwave/orm/activerecord'

CarrierWave.root = '.'

CarrierWave.configure do |config|

  config.asset_host = Import.global('config.asset_host') if Import.global?('config.asset_host')

  if Import.global?('config.aws_secret_key')
    config.storage = :fog
    config.fog_credentials  = {
      provider:               'AWS',
      aws_access_key_id:      Import.global('config.aws_access_key'),
      aws_secret_access_key:  Import.global('config.aws_secret_key'),
      region:                 Import.global('config.aws_region')
    }
    config.fog_directory    = Import.global('config.aws_bucket')
  else
    config.storage            = :file
    config.enable_processing  = true
  end
end
