require_relative '../permission'

PersonResource::Permission = Buzzn::Permission.new(PersonResource) do
  # define groups of roles
  define_group(:none)
  define_group(:self, Role::SELF)
  define_group(:ops, Role::SELF, Role::BUZZN_OPERATOR)

  # top level CRUD permissions
  create :none
  retrieve :ops
  update :self
  delete :none

  # nested method and its CRUD permissions, missing ones means no permissions
  address do
    create :self
    retrieve :ops
    update :self
    delete :self
  end

  bank_accounts  do
    crud(:self)
  end
end
