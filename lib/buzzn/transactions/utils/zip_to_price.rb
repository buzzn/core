require_relative '../utils'
require_relative '../../schemas/transactions/utils/zip_to_price'
require_relative '../../types/zip_prices'

class Transactions::Utils::ZipToPrice < Transactions::Base

  validate :schema
  step :zip_to_price

  def zip_to_price(input)
    prices = Types::ZipPrices.new(input)
    if result = prices.max_price
      Success(result)
    else
      Failure(Buzzn::GeneralError.new(zip: ['no price for zip found']))
    end
  end

  def schema
    Schemas::Transactions::Utils::ZipToPrice
  end

end
