Buzzn::Permission.new(Admin::LocalpoolResource) do

  # define groups of roles
  group(:none)
  group(:operators, :admin, :buzzn_operator)
  # get the roles from the 'operators' group and add :localpool_owner
  group(:owners, *(get(:operators) + [:localpool_owner]))
  # get the roles from the 'owners' group and add :localpool_manager
  group(:managers,*(get(:owners) + [:localpool_manager]))
  group(:managers_contract, *(get(:managers) + [:contract]))
  group(:managers_organization, *(get(:managers) + [:organization]))
  group(:managers_organization_self, *(get(:managers_organization) + [:self]))
  group(:managers_self, *(get(:managers) + [:self]))
  group(:all, *(get(:managers) + [:localpool_member]))

  # top level CRUD permissions
  create :operators
  retrieve :all
  update :managers
  delete :operators

  # nested method and its CRUD permissions, missing ones means no permissions
  energy_producers do
    retrieve :managers
  end

  energy_consumers do
    retrieve :managers
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

    address do
      crud :managers_organization
    end

    bank_accounts do
      crud :managers_organization
    end
  end

  registers do
    retrieve :managers_contract
    update :managers
    delete :none

    readings do
      create :managers
      retrieve :managers_contract
      update :none
      delete :managers
    end
  end

  contracts do
    retrieve :managers_contract
    update :managers
    delete :none

    address do
      create :managers
      retrieve :managers
      update :managers
      delete :managers
    end

    register do
      create :none
      retrieve :managers_contract
      update :managers
      delete :none
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

    # reuse permissions from 'registers'
    registers '/registers'

    formula_parts do
      create :managers
      retrieve :managers
      update :managers
      delete :none

      # reuse permissions from 'registers'
      register '/registers'
    end
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

  managers do
    create :managers
    retrieve :managers
    update :managers
    delete :operators

    bank_accounts do
      retrieve :none
    end
  end

  prices do
    crud :managers
  end

  billing_cycles do
    create :managers
    retrieve :all
    update :managers
    delete :managers
    
    billings do     
      create :managers
      retrieve :all
      update :managers
      delete :managers
    end
  end

  scores do
    retrieve :all
  end
end
