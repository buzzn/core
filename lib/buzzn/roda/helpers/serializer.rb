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

      def handle_right(value, request)
        if request.response.status.nil? && value.is_a?(Buzzn::Resource::Base)
          request.response.status = infer_status(value.object)
        end
        value
      end

      def handle_left(value, request)
        errors = []
        value.errors.each do |name, messages|
          messages.each do |message|
            errors << { parameter: name,
                        detail: message }
          end
        end
        request.response.status = ErrorHandler::ERRORS[value.class] || 500
        "{\"errors\":" << errors.to_json << "}"
      end

      def call(object, request)
        options = {include: Buzzn::IncludeParser.parse(request.params['include'])}
        case object
        when Dry::Monads::Either::Right
          handle_right(object.value, request).to_json(options)
        when Dry::Monads::Either::Left
          handle_left(object.value, request)
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
