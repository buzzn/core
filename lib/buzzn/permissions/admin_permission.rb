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

    bank_accounts do
      retrieve :managers
    end

    contracts do
      retrieve :managers

      localpool do
        retrieve :managers
      end

      billings do
        retrieve :managers
      end

      register_meta do
        retrieve :managers
        registers do
          retrieve :managers
        end
      end
    end
  end

  organizations do
    retrieve :managers

    contact do
      retrieve :managers
      address do
        retrieve :managers
      end
    end

    legal_representation do
      retrieve :managers
    end

    address do
      retrieve :managers
    end

    contracts do
      retrieve :managers

      localpool do
        retrieve :managers
      end

      register_meta do
        retrieve :managers
        registers do
          retrieve :managers
        end
      end
    end
  end

  localpools do
    retrieve :managers
    create :operators
  end

  organization_markets do
    create :operators
    update :operators
    retrieve :managers

    address do
      create :operators
      update :operators
      retrieve :managers
    end

    market_functions do
      create :operators
      update :operators
      retrieve :managers

      contact_person do
        retrieve :managers
        update :operators
        address do
          retrieve :managers
        end
      end

      address do
        retrieve :managers
        update :operators
        address do
          retrieve :managers
        end
      end
    end
  end
end
