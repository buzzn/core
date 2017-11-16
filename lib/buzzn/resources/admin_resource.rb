require_relative 'organization_resource'
require_relative 'person_resource'

class AdminResource < Buzzn::Resource::Base

  has_many :persons, PersonResource
  has_many :organizations, OrganizationResource

  # FIXME move into constructor once the Resource::Base allows it
  def self.new(user)
    super(Admin::LocalpoolResource.all(user).objects,
          current_user: user,
          current_roles: permissions.retrieve,
          permissions: permissions)
  end
end
