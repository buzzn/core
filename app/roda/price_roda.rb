class PriceRoda < BaseRoda
  plugin :shared_vars
  plugin :created_deleted

  include Import.args[:env,
                      'transaction.create_price',
                      'transaction.update_price']

  route do |r|

    localpool = shared[:localpool]

    r.get! do
      localpool.prices
    end

    r.post! do
      created do
        create_price.call(r.params,
                          resource: [localpool.method(:create_price)])
      end
    end

    r.patch! :id do |id|
      price = localpool.price(id)
      update_price.call(r.params, resource: [price])
    end
  end
end
