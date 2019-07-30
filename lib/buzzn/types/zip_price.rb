require_relative '../types'

module Types

  MeterTypes = Types::Strict::String.enum('single', 'double', 'smart')

  class ZipPrice

    extend Dry::Initializer

    option :price
    option :type, type: MeterTypes
    option :annual_kwh, Types::Strict::Int

    def config
      @config ||= CoreConfig.load(Types::ZipPriceConfig)
    end

    def raw_unit_cents_netto
      case type
      when 'single'
        price.unitprice_cents_kwh_et
      when 'smart'
        price.unitprice_cents_kwh_et
      when 'double'
        price.unitprice_cents_kwh_dt
      else
        raise "can not handle #{type}"
      end
    end

    def unit_cents_netto
      config.kwkg_aufschlag + config.strom_nev + config.ab_la_v +
        config.stromsteuer + config.eeg_umlage + config.offshore_haftung +
        config.deckungs_beitrag + config.energie_preis +
        price.ka + raw_unit_cents_netto
    end

    def yearly_euro_netto_double
      price.measurement_euro_year_dt +  price.baseprice_euro_year_dt + config.yearly_euro_intern
    end

    def yearly_euro_netto_single
      price.measurement_euro_year_et +  price.baseprice_euro_year_et + config.yearly_euro_intern
    end

    def yearly_euro_netto_smart
      price.baseprice_euro_year_et + config.yearly_euro_intern;
    end

    def yearly_euro_netto
      case type
      when 'single'
        yearly_euro_netto_single
      when 'double'
        yearly_euro_netto_double
      when 'smart'
        yearly_euro_netto_smart
      else
        raise "can not handle #{type}"
      end
    end

    def baseprice_cents_per_month
      @baseprice ||= (yearly_euro_netto * config.vat / 0.12).round.to_i
    end

    def energyprice_cents_per_kilowatt_hour
      @energyprice ||= (unit_cents_netto * config.vat).round.to_i
    end

    def total_cents_per_month
      @total ||= baseprice_cents_per_month + (annual_kwh * energyprice_cents_per_kilowatt_hour / 12.0).round.to_i
    end

    def to_json(*)
      @json ||= '{"baseprice_cents_per_month":' << baseprice_cents_per_month.to_s << ',"energyprice_cents_per_kilowatt_hour":' << energyprice_cents_per_kilowatt_hour.to_s << ',"total_cents_per_month":' << total_cents_per_month.to_s << '}'
    end

  end

end
