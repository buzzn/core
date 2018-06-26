require_relative '../base_roda'

module Website
  class ZipToPriceRoda < BaseRoda

    include Import.args[:env, 'transactions.website.zip_to_price']

    route do |r|

      r.post! do
        zip_to_price.(params: r.params)
      end
    end

  end
end
