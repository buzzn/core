module Buzzn
  module Roda
    class Serializer

      def logger
        @logger ||= Buzzn::Logger.new(self)
      end

      def call(object, request)
        options = {include: Buzzn::IncludeParser.parse(request.params['include'])}
        case object
        when Dry::Monads::Either::Right
          if object.value.created_at == object.value.updated_at
            request.response.status = 201
          end
          object.value.to_json(options)
        when Dry::Monads::Either::Left
          errors = []
          object.value.errors.each do |name, messages|
            messages.each do |message|
              errors << { parameter: name,
                          detail: message }
            end
          end
          request.response.status = ErrorHandler::ERRORS[object.value.class] || 500
          "{\"errors\":#{errors.to_json}}"
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
