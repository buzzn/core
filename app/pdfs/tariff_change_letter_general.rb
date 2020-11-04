require_relative 'a0x_general'

module Pdf
  class TariffChangeLetterGeneral < A0xGeneral

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Strompreisanpassung-#{contract.localpool.base_slug}-#{contract.contract_number}-#{contract.contract_number_addition}-#{contract.contact.last_name}"
    end

    def preis_sentence(subject, previous, next_one, currency)
      if previous < next_one
        "Der #{subject} steigt von derzeit #{german_div(previous)} #{currency} auf #{german_div(next_one)}  #{currency}."
      elsif previous > next_one
        "Der #{subject} sinkt von derzeit #{german_div(previous)} #{currency} auf #{german_div(next_one)}  #{currency}."
      else
        "Der #{subject} bleibt bei #{german_div(next_one)} #{currency}."
      end
    end

    def example_sentence(consumption, old, new_one)
      old_price = old.baseprice_cents_per_month * @vat.amount * 12 + consumption * old.energyprice_cents_per_kwh * @vat.amount
      new_price = new_one.baseprice_cents_per_month * @vat.amount * 12 + consumption * new_one.energyprice_cents_per_kwh * @vat.amount

      if old_price < new_price
        "Bei Ihrem Jahresverbrauch von #{consumption} kWh bedeutet diese Preisanpassung eine Steigerung von #{german_div(old_price)} € auf #{german_div(new_price)} € pro Jahr."
      else
        "Bei Ihrem Jahresverbrauch von #{consumption} kWh bedeutet diese Preisanpassung eine Senkung von #{german_div(old_price)} € auf #{german_div(new_price)} € pro Jahr."
      end
    end

    def build_struct
      now = Date.today
      @upcoming = nil
      Service::Tariffs.data(@contract.tariffs).each do |tariff|
        if tariff.begin_date >= now
          @upcoming = tariff.tariff
          break
        end
      end
      super.tap do |h|
        h[:tariff_begin] = @upcoming.begin_date.strftime('%d.%m.%Y')
        h[:example_sentence] = example_sentence(@contract.current_payment.energy_consumption_kwh_pa, @contract.current_tariff, @upcoming)
        h[:is_pre_contract] = true
        h[:document_name] = 'Strompreisanpassung zum ' + @upcoming.begin_date.strftime('%d.%m.%Y')
        h[:upcoming_tariff] = build_tariff(@upcoming)
        h[:baseprice_sentence] = preis_sentence('Grundpreis', @contract.current_tariff.baseprice_cents_per_month * @vat.amount, @upcoming.baseprice_cents_per_month * @vat.amount, '€/Monat')
        h[:energyprice_sentence] = preis_sentence('Arbeitspreis', 100*@contract.current_tariff.energyprice_cents_per_kwh * @vat.amount, 100*@upcoming.energyprice_cents_per_kwh * @vat.amount, 'Cent/kWh')
      end
    end

    def document_purpose
      'tariff_change_letter'
    end

  end
end
