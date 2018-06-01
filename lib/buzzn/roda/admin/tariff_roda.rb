require_relative '../admin_roda'

module Admin
  class TariffRoda < BaseRoda

  include Import.args[:env,
                      'transactions.admin.tariff.create',
                      'transactions.admin.tariff.delete',
                     ]

    plugin :shared_vars

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        create.(resource: localpool, params: r.params)
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
          delete.(resource: tariff)
        end
      end
    end

  end
end
