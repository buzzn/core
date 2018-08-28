require_relative '../action'
require_relative 'update'

module Operations::Action
  class CreateOrUpdateOrganization < Update

    def call(params:, resource:, method:, force_new: false, **)
      org_resource = resource&.send(method)
      org_params = params[method]
      if !force_new && org_resource && org_params && !org_params.key?(:id)
        super(params: params.delete(method), resource: org_resource)
      elsif org_params
        params[method] = find_or_create(org_params)
      end
    end

    private

    def find_or_create(org_params)
      if org_params.size == 1 && org_params.key?(:id)
        Organization::General.find(org_params[:id])
      else
        Organization::General.create(org_params)
      end
    end

  end
end
