class Roda
  module RodaPlugins

    module TerminalVerbs

      # Require the all_verbs plugin
      def self.load_dependencies(app)
        app.plugin :all_verbs
      end

      module RequestMethods

        STATUS = {delete: 204, patch: 200, put: 200, post: 201, get: 200}

        %i'delete patch put post get'.each do |verb|
          class_eval(<<-END, __FILE__, __LINE__+1)
            def #{verb}!(*args, &block)
               # we need to tackle the root path somehow
               # only empty remaining_path will match TERM marker !
               @remaining_path = '' if @remaining_path == '/'
               ((@verbs ||= {})[path] ||= []) << :#{verb}
               if_match(args + [Roda::RodaPlugins::Base::RequestMethods::TERM]) do |*bargs|
                 response.status = STATUS[:#{verb}]
                 block.call(*bargs) if block
              end if #{verb}?
            end
            def others!(*args, &block)
              if_match(args + [Roda::RodaPlugins::Base::RequestMethods::TERM]) do |*bargs|
                response.status = 405
                response.headers['X-Allowed-Methods'] = ((@verbs ||= {})[path] ||= []).uniq.collect(&:to_s).join(', ')
                block.call(*bargs) if block
              end
            end
          END
        end

      end

    end

    register_plugin(:terminal_verbs, TerminalVerbs)

  end
end
