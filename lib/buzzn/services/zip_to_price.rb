module Buzzn
  module Services
    class ZipToPrice

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

      def intialize
        @config = DEFAULT_CONFIG
      end

      def total_price(zip: zip, type: type, anual_kwh: annual_kwh)
        prices = ZipPrices.new(zip: zip, type: type, annual_kwh: annual_kwh,
                            config: config)
        prices.total_price_cents
      end
    end
  end
end
