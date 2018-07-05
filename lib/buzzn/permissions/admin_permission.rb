require_relative '../permission'

AdminResource::Permission = Buzzn::Permission.new(AdminResource) do
  define_group(:managers, :admin, :buzzn_operator, :group_admin)
  define_group(:operators, :admin, :buzzn_operator)

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

      market_location do
        retrieve :managers
        register do
          retrieve :managers
        end
      end
    end
  end

  organizations do
    retrieve :managers

    contact do
      retrieve :managers
    end
  end

  localpools do
    retrieve :managers
    create :operators
  end
end
