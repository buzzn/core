require 'bundler'
Bundler.setup

require 'active_record'
require 'dotenv/load'
require 'ap'

module Beekeeper; end

Dir.glob('lib/models/*.rb').each { |path| require path }

ActiveRecord::Base.establish_connection(ENV['BEEKEEPER_DATABASE_URL'])