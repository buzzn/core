module Buzzn
  module Roda
    class Serializer

      def logger
        @logger ||= Buzzn::Logger.new(self)
      end

      def call(object, request)
        options = {include: ''}
        if include = request.params['include']
          #binding.pry
          options[:include] = include.empty? ? '' : eval("{#{include.gsub(/(,|$)/, ':{}\1')}}")
        end
        case object
        when Dry::Monads::Either::Right
          object.value.to_json(options)
        when Dry::Monads::Either::Left
          errors = []
          object.value.errors.each do |name, messages|
            messages.each do |message|
              errors << { parameter: name,
                          detail: message }
            end
          end
          "{\"errors\":#{errors.to_json}}"
        when NilClass
          # response with 404 unless otherwise set
        when ActiveRecord::Relation
          Buzzn::SerializableResource.new(object).to_json(options)
        else
          time = Time.now.to_f
          result = object.to_json(options)
          ended = Time.now.to_f
          logger.info do
            clazz = object.is_a?(Buzzn::Resource::Collection)? "Collection[#{object.first.class}] size: #{object.size}" : object.class
            "#{clazz} bytes: #{result.size} time: #{ended - time}"
          end
          result
        end
      end
    end
  end
end
