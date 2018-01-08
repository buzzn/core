$LOAD_PATH << './lib'

require 'buzzn/boot/init'
require 'buzzn/logger'

Buzzn::Logger.root = ::Logger.new(STDOUT).tap do |logger|
  logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
  logger.level = ENV['LOG_LEVEL'] || 'debug'
end

Dir['config/initializers/*.rb'].each { |f| require "./#{f}" }

Buzzn::Boot::Init.run
