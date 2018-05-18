require_relative '../admin_roda'
require_relative '../../transactions/admin/tariff/create'
require_relative '../../transactions/admin/tariff/delete'

module Admin
  class TariffRoda < BaseRoda

    plugin :shared_vars

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        Transactions::Admin::Tariff::Create.(
          resource: localpool,
          params: r.params
        )
      end

      tariffs = localpool.tariffs
      r.get! do
        tariffs
      end

      r.on :id do |id|
        tariff = tariffs.retrieve(id)

        r.get! do
          tariff
        end

        r.delete! do
          Transactions::Admin::Tariff::Delete
            .call(tariff)
        end
      end
    end

  end
end
