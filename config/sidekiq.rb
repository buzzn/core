$LOAD_PATH << './lib'

require 'buzzn/boot/sidekiq_runner'

Buzzn::Boot::SidekiqRunner.run(::Logger.new(STDOUT).tap do |logger|
  logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
end)
