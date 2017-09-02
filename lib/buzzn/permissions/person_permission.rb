Buzzn::Permission.new(PersonResource) do
  group(:none)
  group(:self, :self)

  create :none
  retrieve :self
  update :self
  delete :none

  address do
    crud(:self)
  end

  bank_accounts '/address'
end
