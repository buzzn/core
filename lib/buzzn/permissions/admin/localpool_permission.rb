Buzzn::Permission.new(Admin::LocalpoolResource) do

  # define groups of roles
  group(:none)
  group(:operators, Role::BUZZN_OPERATOR)
  # get the roles from the 'operators' group and add Role::GROUP_OWNER
  group(:owners, *(get(:operators) + [Role::GROUP_OWNER]))
  # get the roles from the 'owners' group and add Role::GROUP_ADMIN
  group(:managers,*(get(:owners) + [Role::GROUP_ADMIN]))
  group(:managers_contract, *(get(:managers) + [Role::CONTRACT]))
  group(:managers_organization, *(get(:managers) + [Role::ORGANIZATION]))
  group(:managers_organization_self, *(get(:managers_organization) + [Role::SELF]))
  group(:managers_self, *(get(:managers) + [Role::SELF]))
  group(:all, *(get(:managers) + [Role::GROUP_MEMBER]))

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
      address do # TODO Ralf: is the address of the contact of an organization of any relevance ?
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
