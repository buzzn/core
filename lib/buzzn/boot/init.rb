require_relative '../../buzzn'
require_relative 'reader'
require_relative 'active_record'
require_relative 'main_container'
require_relative '../services'
require 'pry'
require 'dry/auto_inject'
require 'dry-dependency-injection'

# core extensions
require_relative '../core/number'

Import = Dry::AutoInject(Buzzn::Boot::MainContainer)
def Import.global(key)
  container[key]
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

          # preload singletons
          singletons = Singletons.new
          singletons.config.lazy = Import.global('config.lazy_services') == 'true'
          importer = Dry::DependencyInjection::Importer.new(singletons)
          importer.import('lib/buzzn', 'services')
          importer.import('lib/buzzn', 'operations')

          MainContainer.merge(singletons)

          # finalize after we have the complete MainContainer setup
          singletons.finalize

          # eager require some files
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
