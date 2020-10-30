require_relative 'a0x_general'

module Pdf
  class TariffChangeLetterGeneral < A0xGeneral

    protected

    def title
      'Strompreisanpassung zum 1.1.2021'
    end

    def preis_sentence(subject, previous, next_one, currency)
      if previous < next_one
        "Der #{subject} steigt von derzeit #{german_div(previous)} #{currency} auf #{german_div(next_one)}  #{currency}."
      elsif previous > next_one
        "Der #{subject} sinkt von derzeit #{german_div(previous)} #{currency} auf #{german_div(next_one)}  #{currency}."
      else
        "Der #{subject} bleibt bei #{next_one}  #{currency}."
      end
    end

    def build_struct
      now = Date.today
      upcoming = nil
      Service::Tariffs.data(@contract.tariffs).each do |tariff|
        if tariff.begin_date >= now
          upcoming = tariff.tariff
          break
        end
      end
      super.tap do |h|
        h[:is_pre_contract] = true
        h[:document_name] = 'Strompreisanpassung zum 01.02.2021'
        h[:upcoming_tariff] = build_tariff(upcoming)
        h[:baseprice_sentence] = preis_sentence('Grundpreis', @contract.current_tariff.baseprice_cents_per_month_after_taxes, upcoming.baseprice_cents_per_month_after_taxes, 'Euro/Monat')
        h[:energyprice_sentence] = preis_sentence('Arbeitspreis', @contract.current_tariff.energyprice_cents_per_kwh_after_taxes, upcoming.energyprice_cents_per_kwh_after_taxes, 'Cent/kWh')
      end
    end

    def document_purpose
      'tariff_change_letter'
    end

  end
end
