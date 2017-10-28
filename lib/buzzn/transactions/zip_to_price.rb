require_relative '../schemas/transactions/utils/zip_to_price'

class Buzzn::Transaction
  define do |t|

    t.register_step(:zip_to_price_step) do |input|
      prices = Buzzn::Types::ZipPrices.new(input)
      if result = prices.max_price
        Dry::Monads.Right(result)
      else
        Dry::Monads.Left(Buzzn::GeneralError.new(zip: ['no price for zip found']))
      end
    end

    t.define(:zip_to_price) do
      validate  Schemas::Transactions::Utils::ZipToPrice
      step :zip_to_price_step
    end
  end
end
