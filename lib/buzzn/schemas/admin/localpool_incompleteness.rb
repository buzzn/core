require_relative '../organization_incompleteness'
require_relative '../../resources/organization_resource'

module Admin
  LocalpoolIncompleteness = Dry::Validation.Schema do

    configure do
      config.messages_file = 'config/errors.yml'
      def valid_role?(input)
        case input
        when PersonResource
          role = input.object.roles.where(name: Role::GROUP_OWNER).detect do |r|
            (r.resource.owner.is_a?(Person) && input.id == r.resource.owner.id) || (r.resource.owner.is_a?(Organization) && r.resource.owner.legal_representation && input.id == r.resource.owner.legal_representation.id)
          end
          role != nil
        when OrganizationResource
          valid_role?(input.legal_representation)
        when NilClass
          true
        else
          raise "can not handle #{input.class}"
        end
      end
    end

    required(:owner) do
      ((filled?.and type?(OrganizationResource)).then schema(OrganizationIncompleteness)).and valid_role?.and filled?
    end

  end
end
