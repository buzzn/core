require_relative '../../permission'

Organization::MarketResource::Permission = Buzzn::Permission.new(Organization::MarketResource) do

  # define groups of roles
  define_group(:ops, Role::BUZZN_OPERATOR)

  # top level CRUD permissions
  crud :ops

end
