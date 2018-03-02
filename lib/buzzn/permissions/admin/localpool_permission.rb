require_relative '../../permission'

Admin::LocalpoolResource::Permission = Buzzn::Permission.new(Admin::LocalpoolResource) do

  # define groups of roles
  define_group(:none)
  define_group(:operators, Role::BUZZN_OPERATOR)
  # get the roles from the 'operators' group and add Role::GROUP_OWNER
  define_group(:owners, *(get(:operators) + [Role::GROUP_OWNER]))
  # get the roles from the 'owners' group and add Role::GROUP_ADMIN
  define_group(:managers, *(get(:owners) + [Role::GROUP_ADMIN]))
  define_group(:managers_contract, *(get(:managers) + [Role::CONTRACT]))
  define_group(:managers_organization, *(get(:managers) + [Role::ORGANIZATION]))
  define_group(:managers_organization_self, *(get(:managers_organization) + [Role::SELF]))
  define_group(:managers_self, *(get(:managers) + [Role::SELF]))
  define_group(:all, *(get(:managers) + [Role::GROUP_MEMBER]))

  # top level CRUD permissions
  create :operators
  retrieve :all
  update :managers
  delete :operators

  # nested method and its CRUD permissions
  distribution_system_operator do
    retrieve :operators
  end

  transmission_system_operator do
    retrieve :operators
  end

  electricity_supplier do
    retrieve :operators
  end

  bank_account do
    retrieve :operators
  end

  energy_producers do
    retrieve :managers
  end

  registers do
    crud :managers
  end

  persons do
    create :managers
    retrieve :managers_self
    update :managers_self
    delete :none

    address do
      crud :managers_self
    end

    bank_accounts :address
  end

  owner do
    retrieve :managers
    create :operators
    update :operators
    contact '/persons'
    legal_representation do
      retrieve :managers
    end
    address do
      crud :managers_self
    end

    bank_accounts :address
  end

  gap_contract_customer '/owner'

  energy_consumers do
    retrieve :managers
  end

  address do
    create :managers
    retrieve :managers
    update :managers
    delete :none
  end

  organizations do
    crud :managers

    contact do
      retrieve :managers_organization
      update :managers_organization
      delete :none
      address do
        retrieve :managers_organization
        update :managers_organization
        delete :none
      end
    end

    legal_representation do
      retrieve :managers_organization
      update :managers_organization
      delete :none
    end

    address do
      crud :managers_organization
    end

    bank_accounts do
      crud :managers_organization
    end
  end

  market_locations do
    retrieve :managers_contract
    update :managers
    delete :none

    register do
      retrieve :managers_contract
      meter do
        retrieve :managers_contract
      end
    end

    contracts do
      retrieve :managers_contract

      customer do
        retrieve :managers_contract
        contact do
          retrieve :managers_contract
        end
      end
    end

  end

  contracts do
    retrieve :managers_contract
    update :managers
    delete :none

    localpool do
      retrieve :managers_contract
    end

    market_location do
      retrieve :managers_contract

      register do
        create :none
        retrieve :managers_contract
        update :managers
        delete :none
        meter do
          retrieve :managers_contract
        end
      end
    end

    contractor do
      create :none
      retrieve :managers_contract
      update :managers
      delete :none

      # reuse permissions from 'organizations' -> 'contact'
      contact '/organizations/contact'

      address do
        retrieve :managers_organization_self
        update :managers_organization_self
        delete :none
      end

      bank_accounts do
        retrieve :managers_organization_self
        update :managers_organization_self
        delete :none
      end
    end

    contractor_bank_account do
      create :none
      retrieve :managers_contract
      update :managers
      delete :none
    end

    # reuse permissions from sibling 'contractor_bank_account'
    customer_bank_account :contractor_bank_account

    # reuse permissions from sibling 'contractor'
    customer :contractor

    tariffs do
      retrieve :managers_contract
    end

    payments :tariffs
  end

  # reuse permissions from 'contracts'
  localpool_power_taker_contracts '/contracts'

  # reuse permissions from 'contracts'
  localpool_processing_contract '/contracts'

  # reuse permissions from 'contracts'
  metering_point_operator_contract '/contracts'

  meters do
    retrieve :managers
    update :managers
    delete :operators

    address do
      create :managers
      retrieve :managers
      update :managers
      delete :managers
    end

    registers do
      retrieve :managers
      update :managers
      delete :operators

      market_location '/market_locations'

      readings do
        create :managers
        retrieve :managers_contract
        update :none
        delete :managers
      end
    end

    formula_parts do
      create :managers
      retrieve :managers
      update :managers
      delete :none

      register do
        retrieve :managers
      end
    end
  end

  managers do
    create :managers
    retrieve :managers
    update :managers
    delete :operators

    bank_accounts do
      retrieve :none
    end
  end

  tariffs do
    create :operators
    retrieve :all
    delete :operators
  end

  billing_cycles do
    create :managers
    retrieve :all
    update :managers
    delete :managers

    bricks do
      retrieve :managers
    end

    billings do
      create :managers
      retrieve :all
      update :managers
      delete :managers
    end
  end
end
