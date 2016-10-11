module Buzzn

  class Price
    attr_reader :energyprice_cents, :baseprice_cents, :total_cents

    def initialize(baseprice_cents, energyprice_cents, total_cents)
      @energyprice_cents = energyprice_cents.to_i
      @baseprice_cents   = baseprice_cents.to_i
      @total_cents       = total_cents.to_i
    end

    def to_f
      @total_cents
    end

    def to_h
      { energyprice_cents: @energyprice_cents,
        baseprice_cents: @baseprice_cents,
        total_cents: @total_cents }
    end

    def <=>(other)
      self.to_f <=> other.to_f
    end
  end

  class Zip2Price

    KWKG_AUFSCHLAG   = 0.445
    AB_LA_V          = 0
    STROM_NEV        = 0.378
    STROMSTEUER      = 2.050
    EEG_UMLAGE       = 6.354
    OFFSHORE_HAFTUNG = 0.04
    DECKUNGSBEITRAG  = 1
    ENERGIEPREIS     = 5.02
    GPINTERN         = 40.20
    MWST             = 1.19
    DEFAULT_KA       = 0.11

    class << self
      def type_to_method
        {
          single_tarif_meter: :netto_general,
          double_tarif_meter: :netto_double,
          smartmeter:         :netto_smartmeter,
          other:              :netto_general,
          dont_know:          :netto_general
        }
      end

      def types
        type_to_method.keys.collect(&:to_s)
      end
    end

    def initialize(kwh, zip, type)
      @type = type
      @kwh = kwh.to_i
      @zip = zip
      @ka = ZipKa.where(zip: zip).first
    end

    def ka?
      !! @ka
    end

    def known_type?
      self.class.types.include? @type
    end

    def calculate(verbandsnummer)
      # verbandsnummer is primary-key
      if nne = NneVnb.where(verbandsnummer: verbandsnummer).first
        energyprice_netto = KWKG_AUFSCHLAG + STROM_NEV + AB_LA_V + STROMSTEUER +
                          EEG_UMLAGE + OFFSHORE_HAFTUNG + DECKUNGSBEITRAG +
                          ENERGIEPREIS +
                          (@ka ? @ka.ka : DEFAULT_KA) +
                          nne.arbeitspreis
        baseprice_netto = send(self.class.type_to_method[@type.to_sym], nne)

        # using cent prices from here and round as the legacy code did:
        # base- and energy prices are round up to the next 10 cents
        # totalprice rounds the regular way
        baseprice_cents   = (baseprice_netto * MWST / 1.2).ceil * 10.0
        energyprice_cents = (energyprice_netto * MWST * 10.0).ceil * 10.0
        total_cents       = (baseprice_cents + @kwh * energyprice_cents / 1200.0).round
        Price.new(baseprice_cents, energyprice_cents, total_cents)
      else
        Price.new(0, 0, 0)
      end
    end
    private :calculate

    def netto_double(nne)
      nne.messung_dt + nne.abrechnung_dt + nne.zaehler_dt + nne.grundpreis + GPINTERN
    end

    def netto_general(nne)
      nne.messung_et + nne.abrechnung_et + nne.zaehler_et + nne.grundpreis + GPINTERN
    end

    def netto_smartmeter(nne)
      nne.grundpreis + GPINTERN
    end

    def to_price
      return nil unless known_type? 
      entries = ZipVnb.where(zip: @zip).collect do |vbn|
        calculate(vbn.verbandsnummer)
      end
      if entries.size > 0
        result = entries.max
        UsedZipSn.create!(zip: @zip, kwh: @kwh, price: result.total_cents)
        result
      end
    end
  end
end
