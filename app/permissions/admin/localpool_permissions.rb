class Admin::LocalpoolPermissions
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
    setting :retrieve, MANAGERS + [:contract]
    setting :update, MANAGERS
    setting :delete, NONE

    setting :register do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :customer do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :customer_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

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

    setting :register do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :customer do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :customer_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor_bank_account do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :tariffs do
      setting :retrieve, MANAGERS + [:contract]
    end

    setting :payments do
      setting :retrieve, MANAGERS + [:contract]
    end
  end

  setting :meters, reader: true do
    setting :retrieve, MANAGERS
    setting :update, MANAGERS
    setting :delete, OPERATORS

    setting :registers do
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE
      
      setting :readings do
        setting :create, MANAGERS
        setting :retrieve, MANAGERS + [:contract]
        setting :update, NONE
        setting :delete, MANAGERS
      end
    end

    setting :formula_parts do
      setting :create, MANAGERS
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE

      setting :register do
        setting :retrieve, MANAGERS
        setting :update, MANAGERS
        setting :delete, NONE
      end
    end
  end

  setting :registers, reader: true do
    setting :retrieve, MANAGERS + [:contract]
    setting :update, MANAGERS
    setting :delete, NONE

    setting :readings do
      setting :create, MANAGERS
      setting :retrieve, MANAGERS + [:contract]
      setting :update, NONE
      setting :delete, MANAGERS
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

    setting :register do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end

    setting :contractor do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :customer do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
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

    setting :register do
      setting :create, NONE
      setting :retrieve, MANAGERS + [:contract]
      setting :update, MANAGERS
      setting :delete, NONE
    end
    setting :contractor do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :customer do
      setting :create, NONE
      setting :retrieve, MANAGERS
      setting :update, MANAGERS
      setting :delete, NONE

      setting :contact do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
        setting :address do
          setting :retrieve, MANAGERS + [:self, :organization_contact]
          setting :update, MANAGERS + [:self, :organization_contact]
          setting :delete, NONE
        end
      end

      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end

      setting :bank_accounts do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
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

  setting :persons, reader: true do
    setting :create, MANAGERS
    setting :retrieve, MANAGERS + [:self]
    setting :update, MANAGERS + [:self]
    setting :delete, NONE

    setting :address do
      setting :create, MANAGERS + [:self]
      setting :retrieve, MANAGERS + [:self]
      setting :update, MANAGERS + [:self]
      setting :delete, MANAGERS + [:self]
    end

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

    setting :contact do
      setting :retrieve, MANAGERS + [:self, :organization_contact]
      setting :update, MANAGERS + [:self, :organization_contact]
      setting :delete, NONE
      setting :address do
        setting :retrieve, MANAGERS + [:self, :organization_contact]
        setting :update, MANAGERS + [:self, :organization_contact]
        setting :delete, NONE
      end
    end

    setting :address do
      setting :create, MANAGERS + [:self, :organization_contact]
      setting :retrieve, MANAGERS + [:self, :organization_contact]
      setting :update, MANAGERS + [:self, :organization_contact]
      setting :delete, MANAGERS + [:self, :organization_contact]
    end

    setting :bank_accounts do
      setting :create, MANAGERS + [:self, :organization_contact]
      setting :retrieve, MANAGERS + [:self, :organization_contact]
      setting :update, MANAGERS + [:self, :organization_contact]
      setting :delete, MANAGERS + [:self, :organization_contact]
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

  setting :scores, reader: true do
    setting :retrieve, ALL
  end
end
