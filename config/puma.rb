# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do |index|
  require 'leafy/core/console_reporter'
  reporter = Leafy::Core::ConsoleReporter::Builder.for_registry(Import.global('service.metrics')) do
    output_to STDERR
    shutdown_executor_on_stop true
  end
  offset = 10 / @options[:workers]
  reporter.start((index + 1) * offset, 10) # report every 10 seconds
  puts("started: #{reporter}\n")

  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

lowlevel_error_handler do |ex, env|
  Raven.capture_exception(
    ex,
    message: ex.message,
    extra: { puma: env },
    transaction: "Puma"
  )
  # note the below is just a Rack response
  [500, {}, ["An error has occurred, and developers have been informed. Please try reloading the page.\n"]]
end
