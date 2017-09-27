Buzzn::Permission.new(AdminResource) do
  group(:managers, :admin, :buzzn_operator, :localpool_manager)

  retrieve :managers

  persons do
    retrieve :managers
  end

  organizations do
    retrieve :managers
  end
end
