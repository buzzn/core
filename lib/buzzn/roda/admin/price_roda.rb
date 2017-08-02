require_relative '../admin_roda'
module Admin
  class PriceRoda < BaseRoda
    plugin :shared_vars
    plugin :created_deleted

    include Import.args[:env,
                        'transaction.create_price',
                        'transaction.update_price']

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        created do
          create_price.call(r.params,
                            resource: [localpool.method(:create_price)])
        end
      end

      prices = localpool.prices
      r.get! do
        prices
      end

      r.on :id do |id|
        price = prices.retrieve(id)

        r.get! do
          price
        end

        r.patch! do
          update_price.call(r.params, resource: [price])
        end
      end
    end
  end
end
