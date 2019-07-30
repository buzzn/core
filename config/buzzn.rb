$LOAD_PATH << './lib'

require 'buzzn/boot/init'

Buzzn::Boot::Init.run(::Logger.new(STDOUT).tap do |logger|
  logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
end)
