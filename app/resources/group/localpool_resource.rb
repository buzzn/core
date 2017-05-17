module Group
  class LocalpoolResource < BaseResource

    model Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :localpool_power_taker_contracts
    has_many :prices
    has_many :billing_cycles

    def localpool_power_taker_contracts
      contracts = all_allowed(permissions.localpool_power_taker_contracts.retrieve,
                              object.localpool_power_taker_contracts,
                              'localpool_id')
      to_collection(contracts, permissions.contracts)
    end

    def contracts
      contracts = all_allowed(permissions.contracts.retrieve,
                              object.contracts, 'localpool_id')
      to_collection(contracts, permissions.contracts)
    end

    def registers
      registers = all_allowed(permissions.registers.retrieve,
                              object.registers, 'group_id')
      to_collection(registers, permissions.registers)
    end

    def users
      perms = permissions.users.retrieve
      enum = object.users

      users = enum.where("EXISTS (?) or EXISTS (?) or id IN (?)",
                         current_user.roles.where('resource_id = ? and name IN (?)', self.id, perms).select(1),
                         unbound_roles(perms),
                         UserResource.bound_resources(current_user, perms))

      user_bound_roles = current_user.roles.where(resource_id: current_user).select(:name).collect{|r| r.name.to_sym}
      @current_roles = @current_roles | user_bound_roles
      to_collection(users, permissions.users)
    end

    def prices
      all(permissions.prices.retrieve) do
        to_collection(object.prices, permissions.prices)
      end
    end

    def billing_cycles
      all(permissions.billing_cycles.retrieve) do
        to_collection(object.billing_cycles, permissions.billing_cycles)
      end
    end

    def create_price(params = {})
      create(permissions.prices.create) do
        params[:localpool] = object
        to_resource(Price.create!(params), permissions.prices)
      end
    end

    def create_billing_cycle(params = {})
      create(permissions.billing_cycles.create) do
        params[:localpool] = object
        to_resource(BillingCycle.create!(params), permissions.billing_cycles)
      end
    end
  end
end
