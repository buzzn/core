require_relative '../../buzzn'
require_relative 'reader'
require_relative 'active_record'
require_relative 'main_container'
require_relative '../services'

require 'dotenv'
require 'pry'
require 'dry/auto_inject'
require 'dry-dependency-injection'

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
  module Services
  end

  module Boot
    class Init
      class Singletons
        include Dry::DependencyInjection::Singletons
      end

      class << self

        def run
          @logger = Logger.new(self)

          setup_environment

          setup_encoding

          setup_initializers

          preload_singletons

          eager_load_some
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

          MainContainer.merge(singletons)

          # finalize after we have the complete MainContainer setup
          singletons.finalize
        end

<<<<<<< HEAD
        def eager_load_some
=======
          # eager require some files
>>>>>>> remove most of the rails setup
          %w( uploaders models pdfs ).each do |sub|
            Dir["./app/#{sub}/**/*.rb"].sort.each do |path|
              require path
            end
          end
          %w(resource resources roda permissions schemas).each do |dir|
            Dir["./lib/buzzn/#{dir}/**/*.rb"].each do |path|
              require path
            end
          end
        end
      end
    end
  end
end
