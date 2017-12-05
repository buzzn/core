require_relative '../../buzzn'
require_relative 'reader'
require_relative 'active_record'
require_relative 'main_container'
require_relative '../services'
require 'dry/auto_inject'
require 'dry/more/container/singleton'

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

      class << self

        def run
          @logger = Logger.new(self)

          # preload singletons
          services = Dry::More::Container::Singleton.new
          services.config.lazy = false
          operations = Dry::More::Container::Singleton.new
          operations.config.lazy = false
          Application.config.paths['lib'].dup.tap do |app|
            app.glob = "buzzn/services/**/*.rb"
            app.to_a.each do |path|
              require path

              main = path.gsub(/^.*buzzn\/|.rb$/, '')
              clazz = main.camelize.safe_constantize
              if clazz # TODO remove if
                if clazz.is_a?(Class)
                  name = main.gsub('/', '.')
                  services.register("#{name.sub(/services/, 'service')}", clazz)
                end
              else
                # TODO remove old namespace handling

                name = File.basename(path).sub(/\.rb/,'')
                cname = name.split('_').collect {|n| n.capitalize }.join
                clazz = Buzzn::Services.const_get(cname)
                services.register("service.#{name}", clazz) if clazz.is_a?(Class)
              end
            end
            app.glob = "buzzn/operations/**/*.rb"
            app.to_a.each do |path|
              require path
              main = path.gsub(/^.*buzzn\/|.rb$/, '')
              clazz = main.camelize.safe_constantize
              name = main.gsub('/', '.')
              if clazz.is_a?(Class)
                operations.register("#{name}", clazz)
              end
            end
          end
          MainContainer.merge(services).merge(operations)
          services.finalize
          operations.finalize

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
