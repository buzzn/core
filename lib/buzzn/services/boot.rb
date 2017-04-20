require_relative 'reader'
require_relative 'main_container'
require 'dry/auto_inject'

Import = Dry::AutoInject(Buzzn::Services::MainContainer)

module Buzzn
  module Services
    class Boot

      class << self

        def before_initialize
          # setup services
          Buzzn::Application.config.paths['app'].dup.tap do |app|
            app.glob = "services/*.rb"
            app.to_a.each do |path|
              require path
              name = File.basename(path).sub(/\.rb/,'')
              cname = name.split('_').collect {|n| n.capitalize }.join
              MainContainer.register("service.#{name}",
                                     Buzzn::Services.const_get(cname).new)
            end
          end
        end
      end
    end
  end
end
