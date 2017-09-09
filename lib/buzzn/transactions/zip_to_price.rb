class Buzzn::Transaction
  define do |t|

    DEFAULT_CONFIG = Buzzn::Types::ZipPriceConfig.new(
        kwkg_aufschlag: 0.445,
        ab_la_v: 0.006,
        strom_nev: 0.388,
        stromsteuer: 2.050,
        eeg_umlage:  6.88,
        offshore_haftung: -0.028,
        deckungs_beitrag: 1.00,
        energie_preis: 5.00,
        vat: 1.19,
        yearly_euro_intern: 41.64
    )

    t.register_validation(:zip_to_price_schema) do
      required(:type).value(included_in?: Buzzn::Types::MeterTypes.values)
      optional(:zip).filled(:int?)
      optional(:annual_kwh).filled(:int?)
    end

    t.register_step(:zip_to_price_step) do |input|
      input[:config] = DEFAULT_CONFIG
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
