require_relative '../permission'

NoPermission = Buzzn::Permission.new(:no_permission) do
  define_group(:none) # empty group

  # no permissions at all
  crud(:none)
end
