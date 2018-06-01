require_relative '../base_roda'

module Utils
  class ZipToPriceRoda < BaseRoda

    include Import.args[:env, 'transactions.utils.zip_to_price']

    route do |r|

      r.post! do
        zip_to_price.(params: r.params)
      end
    end

  end
end
