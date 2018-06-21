require_relative '../action'
require_relative 'update'

module Operations::Action
  class CreateOrUpdatePerson < Update

    def call(params:, resource:, method:, **)
      if (person_resource = resource&.send(method)) && params.key?(method)
        super(params: params.delete(method), resource: person_resource)
      elsif person_params = params[method]
        params[method] = Person.create(person_params)
      end
    end

  end
end
