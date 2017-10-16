PersonResource::Permission = Buzzn::Permission.new(PersonResource) do
  # define groups of roles
  group(:none)
  group(:self, Role::SELF)

  # top level CRUD permissions
  create :none
  retrieve :self
  update :self
  delete :none

  # nested method and its CRUD permissions, missing ones means no permissions
  address do
    crud(:self)
  end

  # reuse permissions from 'address'
  bank_accounts '/address'
end
