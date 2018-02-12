class Roda
  module RodaPlugins

    module Aggregation

      # Require the caching plugin
      def self.load_dependencies(app)
        app.plugin :caching
      end

      module InstanceMethods

        def aggregated(object)
          case object
          when Dry::Monads::Either::Left
            error_response(object)
          when Dry::Monads::Either::Right
            result = object.value
          else
            result = object
          end

          return unless result

          # cache-control headers
          request.etag(result.digest)
          response.expires(result.time_to_live,
                           (current_user ? :private : :public) => true)

          result
        end

        def error_response(monad)
          raise monad.value
        end

      end

    end

    register_plugin(:aggregation, Aggregation)

  end
end
