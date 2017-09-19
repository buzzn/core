require_relative 'base_roda'
require_relative 'utils/zip_to_price_roda'
module Utils
  class Roda < BaseRoda

    route do |r|

      r.on 'zip-to-price' do
        r.run Utils::ZipToPriceRoda
      end

      r.run SwaggerRoda
    end
  end
end
