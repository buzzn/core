require_relative './init'
require_relative '../workers/mail_worker'

require 'redis'
require 'sidekiq'

module Buzzn
  module Boot
    class SidekiqRunner

      class << self

        def run(logger)
          Init.run(logger)
          # create singleton object, sets up the redis connection
          Import.global('services.sidekiq_server')
        end

      end

    end
  end
end
