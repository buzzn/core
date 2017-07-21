class Roda
  module RodaPlugins
    module TerminalVerbs

      # Require the all_verbs plugin
      def self.load_dependencies(app)
        app.plugin :all_verbs
      end

      module RequestMethods
        %w'delete patch put post get'.each do |verb|
          class_eval(<<-END, __FILE__, __LINE__+1)
            def #{verb}!(*args, &block)
               # we need to tackle the root path somehow
               # only empty remaining_path will match TERM marker !
               @remaining_path = '' if @remaining_path == '/'
               if_match(args + [Roda::RodaPlugins::Base::RequestMethods::TERM], &block) if #{verb}?
            end
          END
        end
      end
    end

    register_plugin(:terminal_verbs, TerminalVerbs)
  end
end
