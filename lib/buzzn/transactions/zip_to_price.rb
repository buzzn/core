class Buzzn::Transaction
  define do |t|

    t.register_validation(:zip_to_price_schema) do
      required(:type).value(included_in?: Buzzn::Types::MeterTypes.values)
      optional(:zip).filled(:int?)
      optional(:annual_kwh).filled(:int?)
    end

    t.register_step(:zip_to_price_step) do |input|
      prices = Buzzn::Types::ZipPrices.new(input)
      if result = prices.max_price
        Dry::Monads.Right(result)
      else
        Dry::Monads.Left(Buzzn::GeneralError.new(zip: ['no price for zip found']))
      end
    end

    t.define(:zip_to_price) do
      validate :zip_to_price_schema
      step :zip_to_price_step
    end
  end
end
