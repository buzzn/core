Sidekiq.configure_server do |config|
  config.redis = { url: Import.global('config.redis_url') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Import.global('config.redis_url') }
end
