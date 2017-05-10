class LocalpoolRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    r.get! do
      Group::LocalpoolResource.all(current_user)
    end

    r.on :id do |id|

      shared[:localpool] = localpool = Group::LocalpoolResource.retrieve(current_user, id)

      r.on 'prices' do
        r.run PriceRoda
      end

      r.get! do
        localpool
      end

      r.get! 'localpool-processing-contract' do
        localpool.localpool_processing_contract!
      end

      r.get! 'meteing-point-operator-contract' do
        localpool.metering_point_operator_contract!
      end
    end
  end
end
