require_relative '../utils'
require_relative '../../schemas/transactions/utils/zip_to_price'
require_relative '../../types/zip_prices'

class Transactions::Utils::ZipToPrice < Transactions::Base

  def self.call(input)
    self.for(Schemas::Transactions::Utils::ZipToPrice).call(input)
  end

  step :validate, with: :'operations.validation'
  step :zip_to_price

  def zip_to_price(input)
    prices = Types::ZipPrices.new(input)
    if result = prices.max_price
      Dry::Monads.Right(result)
    else
      Dry::Monads.Left(Buzzn::GeneralError.new(zip: ['no price for zip found']))
    end
  end

end
