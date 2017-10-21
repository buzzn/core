require_relative '../admin_roda'
module Admin
  class TariffRoda < BaseRoda
    plugin :shared_vars
    plugin :created_deleted

    include Import.args[:env,
                        'transaction.create_tariff']

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        created do
          create_tariff.call(r.params,
                            resource: [localpool.method(:create_tariff)])
        end
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
          deleted do
            tariff.delete
          end
        end
      end
    end
  end
end
