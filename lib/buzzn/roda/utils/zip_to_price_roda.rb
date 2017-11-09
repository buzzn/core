require_relative '../base_roda'
require_relative '../../transactions/utils/zip_to_price'

module Utils
  class ZipToPriceRoda < BaseRoda

    route do |r|

      r.post! do
        Transactions::Utils::ZipToPrice.call(r.params)
      end
    end
  end
end
