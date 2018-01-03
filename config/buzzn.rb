$LOAD_PATH << './lib'

require 'dotenv'
require 'buzzn/boot/init'
require 'buzzn/logger'

begin
  list = %W(.env .env.#{ENV['RACK_ENV']} .env.local ).select do |f|
    File.exists?(f)
  end
  Dotenv.load(*list.reverse)
end

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

Buzzn::Logger.root = ::Logger.new(STDOUT).tap do |logger|
  logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
  logger.level = ENV['LOG_LEVEL'] || 'debug'
end

Dir['config/initializers/*.rb'].each { |f| require "./#{f}" }

Buzzn::Boot::Init.run
