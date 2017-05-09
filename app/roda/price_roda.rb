class PriceRoda < BaseRoda
  plugin :shared_vars

  include Import.args[:env, 'transaction.create_price']

  route do |r|

    r.get! do
      shared[:localpool].prices
    end

    r.post! do
      response.status = 201
      create_price.call(r.params,
                        resource: [shared[:localpool].method(:create_price)])
    end
  end
end
