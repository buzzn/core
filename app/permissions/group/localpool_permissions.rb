class Group::LocalpoolPermissions
  extend Dry::Configurable

  ALL = [:admin, :buzzn_operator, :localpool_owner, :localpool_manager, :localpool_member].freeze
  MANAGERS = [:admin, :buzzn_operator, :localpool_owner, :localpool_manager].freeze
  OWNERS = [:admin, :buzzn_operator, :localpool_owner].freeze
  OPERATORS = [:admin, :buzzn_operator].freeze
  NONE = [].freeze

  setting :create, OPERATORS, reader: true
  setting :retrieve, ALL, reader: true
  setting :update, MANAGERS, reader: true
  setting :delete, OPERATORS, reader: true

  setting :energy_producers, reader: true do
    setting :retrieve, MANAGERS
  end

  setting :energy_consumers, reader: true do
    setting :retrieve, MANAGERS
  end

  setting :contracts, reader: true do
    #setting :create, MANAGERS
    setting :retrieve, MANAGERS + [:contract]
    setting :update, MANAGERS
    setting :delete, NONE

    setting :tariffs do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :payments do
      setting :retrieve, MANAGERS + [:contract]
    end
  end

  setting :localpool_power_taker_contracts, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS + [:contract]
    setting :update, MANAGERS
    setting :delete, NONE

    setting :tariffs do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :payments do
      setting :retrieve, MANAGERS + [:contract]
    end
  end

  setting :registers, reader: true do
    setting :retrieve, MANAGERS + [:contract]
    setting :update, MANAGERS
    setting :delete, NONE

    setting :group do
      setting :create, OPERATORS, reader: true
      setting :retrieve, ALL, reader: true
      setting :update, MANAGERS, reader: true
      setting :delete, OPERATORS, reader: true
    end
  end

  setting :localpool_processing_contract, reader: true do
    setting :create, OPERATORS
    setting :retrieve, MANAGERS
    setting :update, MANAGERS
    setting :delete, NONE

    setting :tariffs do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :payments do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :contractor do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :customer do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :signing_user do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :customer_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end
  end

  setting :metering_point_operator_contract, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS
    setting :update, MANAGERS
    setting :delete, NONE

    setting :tariffs do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :payments do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :contractor do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :customer do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :signing_user do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :customer_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
    end
  end
  
  setting :users, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS + [:self]
    setting :update, MANAGERS + [:self]
    setting :delete, OPERATORS

    setting :bank_accounts do
      setting :create, MANAGERS + [:self]
      setting :retrieve, MANAGERS + [:self]
      setting :update, MANAGERS + [:self]
      setting :delete, MANAGERS + [:self]
    end
  end

  setting :organizations, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS
    setting :update, MANAGERS
    setting :delete, MANAGERS
    
    setting :bank_accounts do
      setting :create, MANAGERS + [:organization_contact]
      setting :retrieve, MANAGERS + [:organization_contact]
      setting :update, MANAGERS + [:organization_contact]
      setting :delete, MANAGERS + [:organization_contact]
    end
  end

  setting :managers, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS
    setting :update, MANAGERS
    setting :delete, OPERATORS

    setting :bank_accounts do
      setting :retrieve, NONE
    end
  end

  setting :prices, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS
    setting :update, MANAGERS
    setting :delete, MANAGERS
  end

  setting :billing_cycles, reader: true do
    setting :create, MANAGERS
    setting :retrieve, ALL
    setting :update, MANAGERS
    setting :delete, MANAGERS
    
    setting :billings do
      setting :create, MANAGERS
      setting :retrieve, ALL
      setting :update, MANAGERS
      setting :delete, MANAGERS
    end
  end
end
