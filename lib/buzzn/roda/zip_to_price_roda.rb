require_relative 'base_roda'
class MeRoda < BaseRoda

  include Import.args[:env,
                      'transaction.zip_to_price']

  route do |r|

    r.post! do
      zip_to_price.call(r.params)
    end
  end
end
