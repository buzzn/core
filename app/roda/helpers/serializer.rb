module Buzzn
  module Roda
    class Serializer

      def call(object, request)
        options = {}
        if include = request.params['include']
          options[:include] = eval("{#{include.gsub(/ /, '').gsub(':', ': :').gsub('{', ':{')}}")
        end
        case object
        when Dry::Monads::Either::Right
          Buzzn::SerializableResource.new(object.value).to_json(options)
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
          object.to_json(options)
        end
      end
    end
  end
end
