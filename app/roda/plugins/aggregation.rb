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

          # cache-control headers
          request.etag(Digest::SHA256.base64digest(result.to_json))
          request.last_modified(Time.at(result.respond_to?(:last_timestamp) ?
                                          result.last_timestamp :
                                          result.expires_at))
          response.expires((result.expires_at - Time.current.to_f).to_i,
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
