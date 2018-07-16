require_relative 'organization/general_resource'
require_relative 'organization/market_resource'
require_relative 'person_resource'

class AdminResource < Buzzn::Resource::Base

  has_many :persons, PersonResource
  has_many :organizations, Organization::GeneralResource
  has_many :organization_markets, Organization::MarketResource

  PREFIX = 'SELECT "organizations".* FROM "organizations"'

  def organizations
    # FIXME too much sql hacking of AR
    general = Organization::GeneralResource.all(current_user)
    sql = [general.objects.to_sql, object.organizations.to_sql]
          .collect { |s| s.sub("#{PREFIX} WHERE ", '') }
          .reject { |s| s.downcase.include?(PREFIX) }
          .join(') OR (')
    all = Organization::General.where(sql)
    Organization::GeneralResource.send(:to_collection, all, general.security_context)
  end

  def organization_markets
    Organization::MarketResource.all(current_user)
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
