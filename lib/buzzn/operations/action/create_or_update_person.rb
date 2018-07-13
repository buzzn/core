require_relative '../action'
require_relative 'update'

module Operations::Action
  class CreateOrUpdatePerson < Update

    def call(params:, resource:, method:, **)
      if (person_resource = resource&.send(method)) && params.key?(method)
        if params.size == 1 && params.key?(:id)
          sparams[method] = Person.find(params[:id])
        else
          super(params: params.delete(method), resource: person_resource)
        end
      elsif person_params = params[method]
        if person_params.size == 1 && person_params.key?(:id)
          params[method] = Person.find(person_params[:id])
        else
          params[method] = Person.create(person_params)
        end
      end
    end

  end
end
