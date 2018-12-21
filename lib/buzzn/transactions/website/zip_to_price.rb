require_relative '../website'
require_relative '../../schemas/transactions/website/zip_to_price'
require_relative '../../types/zip_prices'

class Transactions::Website::ZipToPrice < Transactions::Base

  tee :fix_params
  validate :schema
  step :zip_to_price

  def fix_params(params:)
    if params['zip'] && params['zip'].is_a?(String)
      zeroes, params['zip'] = params['zip'].match(/^(0*)(.*)/i).captures
    end
  end

  def schema
    Schemas::Transactions::Website::ZipToPrice
  end

  def zip_to_price(params:)
    prices = Types::ZipPrices.new(params)
    if result = prices.max_price
      Success(result)
    else
      Failure(Buzzn::ValidationError.new(zip: ['no price for zip found']))
    end
  end

end
