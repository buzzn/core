Devise::Async.setup do |config|
  config.backend = :sidekiq
  config.queue   = :default
  config.enabled = true
end