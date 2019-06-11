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
  devices do
    create :managers
    retrieve :managers
    update :managers
    delete :managers
    electricity_supplier do
      retrieve :managers
    end
  end

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

  billing_detail do
    create :managers
    retrieve :managers
    update :managers
  end

  persons do
    create :managers
    retrieve :managers_self
    update :managers_self
    delete :none

    address do
      crud :managers_self
    end

    contracts do
      retrieve :managers_self

      localpool do
        retrieve :managers_self
      end

      register_meta do
        retrieve :managers_self

        registers do
          retrieve :managers_self
        end

      end

    end

    bank_accounts do
      crud :managers_self
    end
  end

  owner do
    retrieve :managers
    create :operators
    update :operators
    contact '/persons'
    legal_representation '/persons'
    address do
      crud :managers_self
    end

    bank_accounts :address
  end

  gap_contract_customer '/owner'

  gap_contract_customer_bank_account do
    retrieve :managers
  end

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
    create :managers
    retrieve :managers_self
    update :managers_self
    delete :none

    contact do
      retrieve :managers_organization
      update :managers_organization
      delete :none
      address do
        retrieve :managers_organization
        update :managers_organization
        delete :none
      end
      bank_accounts do
        crud :managers_organization
      end
    end

    legal_representation do
      retrieve :managers_organization
      update :managers_organization
      delete :none
      address do
        retrieve :managers_organization
        update :managers_organization
        delete :none
      end
      bank_accounts do
        crud :managers_organization
      end
    end

    address do
      crud :managers_organization
    end

    contracts '/persons/contracts'

    bank_accounts do
      crud :managers_organization
    end
  end

  register_metas do
    retrieve :managers_contract
    update :managers
    delete :none

    registers do
      retrieve :managers_contract
      meter do
        retrieve :managers_contract
      end
    end

    # FIXME maybe simply alias to '/contract'
    contracts do
      retrieve :managers_contract

      billings do
        retrieve :managers_contract
      end

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
    document :managers

    localpool do
      retrieve :managers_contract
    end

    accounting_entries do
      create :owners
      update :none
      retrieve :owners
      delete :none
    end

    comments do
      create :owners
      retrieve :owners
      update :owners
      delete :owners
    end

    balance_sheet do
      create :none
      retrieve :owners
      update :none
      delete :none

      entries do
        create :owners
        update :none
        retrieve :owners
        delete :none
      end
    end

    billings do
      create :managers_contract
      retrieve :managers_contract
      update :managers
      delete :managers

      accounting_entry do
        retrieve :managers_contract
      end

      documents do
        create :managers_contract
        retrieve :managers_contract
        delete :managers_contract
      end

      items do
        retrieve :managers_contract
        update :managers

        meter do
          retrieve :managers_contract
        end

        tariff do
          retrieve :managers_contract
        end

        register do
          retrieve :managers_contract

          readings do
            retrieve :managers_contract
          end
        end
      end
    end

    documents do
      create :managers_contract
      retrieve :managers_contract
      delete :managers_contract
    end

    register_meta do
      retrieve :managers_contract

      registers do
        create :none
        retrieve :managers_contract
        update :managers
        delete :none
        meter do
          retrieve :managers_contract
        end
        readings do
          retrieve :managers_contract
        end
      end
    end

    contractor do
      create :none
      retrieve :managers_contract
      update :managers
      delete :none

      # reuse permissions from 'organizations'
      contact              '/organizations/contact'
      legal_representation '/organizations/legal_representation'

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
    contexted_tariffs do
      retrieve :managers_contract

      tariff do
        retrieve :managers_contract
      end
    end

    payments do
      retrieve :managers_contract
      create :managers_contract
      update :managers_contract
      delete :managers_contract

      tariff do
        retrieve :managers_contract
      end
    end
  end

  # reuse permissions from 'contracts'
  localpool_power_taker_contracts '/contracts' do
    create :managers
  end

  localpool_gap_contracts '/contracts' do
    create :managers
  end

  localpool_third_party_contracts '/contracts' do
    create :managers
  end

  localpool_processing_contracts '/contracts' do
    create :managers
  end

  metering_point_operator_contracts '/contracts' do
    create :managers
  end

  meters do
    create :managers
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

      register_meta '/register_metas'

      readings do
        create :managers
        retrieve :managers_contract
        update :none
        delete :managers
      end

      contracts '/contracts'
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

  meters_real    '/meters'
  meters_virutal '/meters'

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

  contexted_gap_contract_tariffs do
    retrieve :managers

    tariff do
      retrieve :managers
    end
  end

  billing_cycles do
    create :managers
    retrieve :all
    update :managers
    delete :managers

    items do
      retrieve :managers
    end

    billings do
      create :managers
      retrieve :all
      update :managers
      delete :managers

      contract '/contracts'
      items do
        retrieve :all

        meter do
          retrieve :all
        end

        tariff do
          retrieve :all
        end

        register do
          retrieve :managers_contract
        end
      end
    end
  end

  reports do
    eeg do
      create :managers
    end
  end
end
