class Roda
  module RodaPlugins
    module CurrentUser

      def self.configure(app, current_user_proc = nil, &block)
        app.opts[:current_user] ||=
          block || current_user_proc || lambda { nil }
      end

      module InstanceMethods
        def current_user
          @current_user ||= opts[:current_user].call(self) if opts.key? :current_user
          env['buzzn.current_user'] = @current_user
        end
      end
    end

    register_plugin(:current_user, CurrentUser)
  end
end
