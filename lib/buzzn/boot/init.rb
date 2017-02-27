require_relative 'reader'
require_relative 'active_record'
require_relative 'main_container'
require 'dry/auto_inject'

Import = Dry::AutoInject(Buzzn::Boot::MainContainer)

module Buzzn
  module Services
  end

  module Boot
    class Init

      class << self

        def before_initialize
          @logger = Buzzn::Logger.new(self)
          # setup services, redo require until no more errors
          # or no more changes in which case there will be an error raised
          Buzzn::Application.config.paths['app'].dup.tap do |app|
            app.glob = "services/*.rb"
            remaining = -1
            errors = init(*app.to_a)
            while errors.size > 0
              if errors.size == remaining
                msg = errors.collect{|k, e| e.message}.join(',')
                raise Dry::Container::Error.new(msg)
              end
              remaining = errors.size
              errors = init(*errors.keys)
            end
          end

          # load transactions
          Application.config.paths['app'].dup.tap do |app|
            app.glob = "transactions/*.rb"
            app.to_a.each { |path| require path }
          end
        end

        private

        def init(*paths)
          errors = {}
          paths.each do |path|
            register(path, errors)
          end
          errors
        end

        def register(path, errors)
          require path
          name = File.basename(path).sub(/\.rb/,'')
          cname = name.split('_').collect {|n| n.capitalize }.join
          begin
            service = Buzzn::Services.const_get(cname).new
            MainContainer.register("service.#{name}", service)
            @logger.info{"registered #{name}: #{service}"}
          rescue Dry::Container::Error => e
            @logger.debug{"register #{name} failed: #{e.message}"}
            errors[path] = e
          end
        end
      end
    end
  end
end
