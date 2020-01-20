require 'sentry-raven'

# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 1)
threads threads_count, threads_count

worker_timeout 3600

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do |index|
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

lowlevel_error_handler do |ex, env|
  Raven.capture_exception(
    ex,
    message: ex.message,
    extra: { puma: env },
    transaction: 'Puma'
  )
  # note the below is just a Rack response
  [500, {'Content-Type'=> 'application/json'}, ['{"errors":["An error has occurred."]}']]
end
