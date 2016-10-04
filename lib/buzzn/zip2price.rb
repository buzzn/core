module Buzzn

  class Price
    attr_reader :workprice, :baseprice, :total

    def initialize(nne, total)
      if nne
        @workprice   = nne.arbeitspreis
        @baseprice   = nne.grundpreis
      end
      @total = total
    end

    def to_f
      @total
    end

    def to_h
      { workprice: @workprice, baseprice: @baseprice, total: @total }
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
        ap_netto = KWKG_AUFSCHLAG + STROM_NEV + AB_LA_V + STROMSTEUER +
                   EEG_UMLAGE + OFFSHORE_HAFTUNG + DECKUNGSBEITRAG +
                   ENERGIEPREIS +
                   (@ka ? @ka.ka : DEFAULT_KA) +
                   nne.arbeitspreis
        gp_netto = send(self.class.type_to_method[@type.to_sym], nne)

        total = ((gp_netto * MWST / 12 + 0.04999).round(1) +
                 @kwh * (ap_netto * MWST + 0.04999).round(1) / 1200).round(2)
        Price.new(nne, total)
      else
        Price.new(nil, 0)
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
      result = entries.max if entries.size > 0
      UsedZipSn.create!(zip: @zip, kwh: @kwh, price: result)
      result
    end
  end
end
