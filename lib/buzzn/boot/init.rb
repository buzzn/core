require_relative '../../buzzn'
require_relative 'reader'
require_relative 'active_record'
require_relative 'main_container'
require_relative '../services'
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
          singletons.config.lazy = false
          importer = Dry::DependencyInjection::Importer.new(singletons)

          Application.config.paths['lib'].dup.tap do |app|
            app.glob = "buzzn/services/**/*.rb"
            app.to_a.each do |path|
              require path

              main = path.gsub(/^.*buzzn\/|.rb$/, '')
              clazz = main.camelize.safe_constantize
              if clazz # TODO remove if
                if clazz.is_a?(Class)
                  name = main.gsub('/', '.')
                  singletons.register("#{name.sub(/services/, 'service')}", clazz)
                end
              else
                # TODO remove old namespace handling

                name = File.basename(path).sub(/\.rb/,'')
                cname = name.split('_').collect {|n| n.capitalize }.join
                clazz = Buzzn::Services.const_get(cname)
                singletons.register("service.#{name}", clazz) if clazz.is_a?(Class)
              end
            end

          end
          importer.import('lib/buzzn', 'operations')
          MainContainer.merge(singletons)
          singletons.finalize

          # eager require some files
          %w(resource resources roda permissions schemas).each do |dir|
            Application.config.paths['lib'].dup.tap do |app|
              app.glob = "buzzn/#{dir}/**/*.rb"
              app.to_a.each { |path| require path }
            end
          end
        end
      end
    end
  end
end
