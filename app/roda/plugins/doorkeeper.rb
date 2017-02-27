class Roda
  module RodaPlugins
    module Doorkeeper

      def self.configure(app, opts={})
        opts = opts.dup
        app.opts[:doorkeeper] = opts
      end

      module InstanceMethods
        def doorkeeper_token
          @doorkeeper_token ||= ::Doorkeeper::OAuth::Token.authenticate(
            ::Doorkeeper::Grape::AuthorizationDecorator.new(request),
            *::Doorkeeper.configuration.access_token_methods
          )
          env['buzzn.doorkeeper_token'] = @doorkeeper_token
        end
      end
    end

    register_plugin(:doorkeeper, Doorkeeper)
  end
end
