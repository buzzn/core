require_relative '../permission'

AdminResource::Permission = Buzzn::Permission.new(AdminResource) do
  define_group(:managers, :admin, :buzzn_operator, :localpool_manager)

  retrieve :managers

  persons do
    retrieve :managers

    address do
      retrieve :managers
    end

    contracts do
      retrieve :managers

      localpool do
        retrieve :managers
      end

      register do
        retrieve :managers
      end
    end
  end

  organizations do
    retrieve :managers
  end
end
