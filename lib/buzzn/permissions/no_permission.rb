NoPermission = Buzzn::Permission.new(:no_permission) do
  group(:none) # empty group

  # no permissions at all
  crud(:none)
end
