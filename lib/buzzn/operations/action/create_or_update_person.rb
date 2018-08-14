require_relative '../action'
require_relative 'update'

module Operations::Action
  class CreateOrUpdatePerson < Update

    def call(params:, resource:, method:, force_new: false, **)
      person_resource = resource&.send(method)
      person_params = params[method]
      if !force_new && person_resource && person_params && !person_params.key?(:id)
        super(params: params.delete(method), resource: person_resource)
      elsif person_params
        params[method] = find_or_create(person_params)
      end
    end

    private

    def find_or_create(person_params)
      if person_params.size == 1 && person_params.key?(:id)
        Person.find(person_params[:id])
      else
        Person.create(person_params)
      end
    end

  end
end
