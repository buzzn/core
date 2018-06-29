require_relative '../../include_parser'

module Buzzn
  module Roda
    class Serializer

      def logger
        @logger ||= Buzzn::Logger.new(self)
      end

      def infer_status(object)
        if object.destroyed?
          204
        elsif object.created_at == object.updated_at
          201
        end
      end

      def handle_success(value, request)
        if request.response.status.nil? && value.is_a?(Buzzn::Resource::Base)
          request.response.status = infer_status(value.object)
        end
        value
      end

      def handle_failure(value, request)
        request.response.status = ErrorHandler::ERRORS[value.class] || 500
        value.errors.to_json
      end

      def call(object, request)
        options = {include: Buzzn::IncludeParser.parse(request.params['include'])}
        case object
        when Dry::Monads::Result::Success
          handle_success(object.value!, request).to_json(options)
        when Dry::Monads::Result::Failure
          handle_failure(object.value, request)
        when NilClass
          # response with 404 unless otherwise set
        else
          time = Concurrent.monotonic_time
          result = object.to_json(options)
          ended = Concurrent.monotonic_time
          logger.debug do
            clazz = object.is_a?(Buzzn::Resource::Collection)? "Collection[#{object.first.class}] size: #{object.size}" : object.class
            "#{clazz} bytes: #{result.size} time: #{ended - time}"
          end
          result
        end
      end

    end
  end
end
