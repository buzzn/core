require_relative 'organization/general_resource'
require_relative 'organization/market_resource'
require_relative 'person_resource'

class AdminResource < Buzzn::Resource::Base

  has_many :persons, PersonResource
  has_many :organizations, Organization::GeneralResource
  has_many :organization_markets, Organization::MarketResource

  def organizations
    general = Organization::GeneralResource.all(current_user)
    org_ids = general.objects.pluck(:id) + object.organizations.pluck(:id)
    org_ids.uniq!
    all = Organization::General.where(:id => org_ids)
    Organization::GeneralResource.send(:to_collection, all, security_context.send(:organizations))
  end

  def organization_markets
    all = Organization::Market.all
    Organization::MarketResource.send(:to_collection, all, security_context.send(:organization_markets))
  end

  def initialize(user)
    current_roles = []
    if user
      current_roles += user.unbound_rolenames
      current_roles += user.uids_to_rolenames.select { |k, v| k.start_with?('Group::Localpool') }.values
    end
    all_roles = current_roles.flatten.uniq.collect { |n| n.downcase.to_sym }
    super(Admin::LocalpoolResource.all(user).objects,
          Buzzn::Resource::SecurityContext.new(user, Permission, all_roles))
  end

end
