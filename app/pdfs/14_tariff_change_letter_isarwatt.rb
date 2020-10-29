require_relative 'a0x_general'
require_relative 'tariff_change_letter_general'

module Pdf
  class TariffChangeLetterIsarwatt < TariffChangeLetterGeneral
    def template_name
      '14_tariff_change_letter_isarwatt.slim'
    end

    def preis_sentence(subject, previous, next_one, currency)
      if previous < next_one
        "erhöhen wir den #{subject} von derzeit #{german_div(previous)} #{currency}/Monat auf #{german_div(next_one)} #{currency}/Monat."
      elsif previous > next_one
        "senken wir den #{subject} von derzeit #{german_div(previous)} #{currency}/Monat auf #{german_div(next_one)} #{currency}/Monat."
      else
        "Der #{subject} bleibt bei #{next_one}  #{currency}."
      end
    end
  end
end
