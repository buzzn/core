require_relative 'organization_resource'
require_relative 'person_resource'

class AdminResource < Buzzn::Resource::Base

  has_many :persons, PersonResource
  has_many :organizations, OrganizationResource

  def initialize(user)
    super(Admin::LocalpoolResource.all(user).objects,
          Buzzn::Resource::Context.new(user,
                                       Permission,
                                       Permission.retrieve))
  end

end
