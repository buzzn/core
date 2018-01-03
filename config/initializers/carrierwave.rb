require 'carrierwave'
require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|

  config.asset_host = ENV['ASSET_HOST'],

  if ENV.key?('AWS_ACCESS_KEY')
    config.storage = :fog
    config.fog_credentials  = {
      provider:               'AWS',
      aws_access_key_id:      ENV['AWS_ACCESS_KEY'],
      aws_secret_access_key:  ENV['AWS_SECRET_KEY'],
      region:                 ENV['AWS_REGION']
    }
    config.fog_directory    = ENV['AWS_BUCKET']
  else
    config.storage            = :file
    config.enable_processing  = true
  end
end
