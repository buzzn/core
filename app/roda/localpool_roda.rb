class LocalpoolRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    r.root do
      Group::LocalpoolResource.all(current_user)
    end

    r.on :id do |id|

      shared[:localpool] = localpool = Group::LocalpoolResource.retrieve(current_user, id)

      r.on 'contracts' do
        r.run ContractRoda
      end

      r.on 'registers' do
        r.run RegisterRoda
      end

      r.on 'meters' do
        r.run MeterRoda
      end

      r.on 'users' do
        r.run UserRoda
      end

      r.on 'organizations' do
        r.run OrganizationRoda
      end

      r.on 'prices' do
        r.run PriceRoda
      end

      r.on 'billing-cycles' do
        r.run BillingCycleRoda
      end

      r.get! do
        localpool
      end

      r.get! 'localpool-processing-contract' do
        localpool.localpool_processing_contract!
      end

      r.get! 'metering-point-operator-contract' do
        localpool.metering_point_operator_contract!
      end

      r.get! 'power-taker-contracts' do
        localpool.localpool_power_taker_contracts
      end
    end
  end
end
