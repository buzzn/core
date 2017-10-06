require_relative '../organization_incompleteness'
require_relative '../../resources/organization_resource'

module Admin
  LocalpoolIncompleteness = Dry::Validation.Schema do
    required(:owner) do
      ((filled?.and type?(OrganizationResource)).then schema(OrganizationIncompleteness)).and filled?
    end
  end
end
