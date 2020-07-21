require_relative '../../buzzn'
require_relative '../../buzzn/resource/security_context'
require_relative 'reader'
require_relative 'active_record'
require_relative 'main_container'
require_relative '../logger'
require_relative '../services'

require 'dotenv'
require 'pry'
require 'dry/auto_inject'
require 'dry-dependency-injection'
require 'roda'

# core extensions
require_relative '../core/number'

Import = Dry::AutoInject(Buzzn::Boot::MainContainer)
def Import.global(key)
  container[key]
end

def Import.global?(key)
  container.key?(key)
end

module Buzzn
  module Boot
    class Init

      class Singletons

        include Dry::DependencyInjection::Singletons

      end

      class << self

        def run(logger)

          setup_environment

          Buzzn::Logger.root = logger
          logger.level = Import.global('config.log_level')
          @logger = Logger.new(self)

          setup_encoding

          setup_initializers

          preload_singletons

          eager_load_some
          Object.const_defined?("Rails") && Rails.logger = @logger
        end

        private

        def setup_environment
          env = Import.global?('config.rack_env') ? Import.global('config.rack_env') : 'development'
          list = %W(.env.local .env.#{env} .env ).select do |f|
            File.exists?(f)
          end
          Dotenv.load(*list)
        end

        def setup_encoding
          Encoding.default_external = Encoding::UTF_8
          Encoding.default_internal = Encoding::UTF_8
        end

        def setup_initializers
          Dir['config/initializers/*.rb'].each { |f| require "./#{f}" }
        end

        def preload_singletons
          # preload singletons
          singletons = Singletons.new
          singletons.config.lazy = Import.global('config.lazy_services') == 'true'
          importer = Dry::DependencyInjection::Importer.new(singletons)
          importer.import('lib/buzzn', 'services')
          importer.import('lib/buzzn', 'operations')
          importer.import('lib/buzzn', 'transactions') do |file|
            !file.include?('steps_adapter')
          end

          MainContainer.merge(singletons)

          # to create resources with injection
          MainContainer.register(:security_context,
                                 Buzzn::Resource::SecurityContext.new)

          # finalize after we have the complete MainContainer setup
          singletons.finalize
        end

        def eager_load_some
          %w( uploaders models pdfs mails ).each do |sub|
            Dir["./app/#{sub}/**/*.rb"].sort.each do |path|
              require path
            end
          end
          %w(resource resources roda permissions schemas workers).each do |dir|
            Dir["./lib/buzzn/#{dir}/**/*.rb"].each do |path|
              require path
            end
          end
        end

      end

    end
  end
end
