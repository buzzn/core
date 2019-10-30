require_relative 'a0x_general'

module Pdf
  class TariffChangeLetter < A0xGeneral

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Strompreisanpassung-#{contract.localpool.base_slug}-#{contract.contract_number}-#{contract.contract_number_addition}"
    end

    def build_struct
      now = Date.today
      upcoming = nil
      Service::Tariffs.data(@contract.localpool.tariffs).each do |tariff|
        if tariff.begin_date >= now
          upcoming = tariff.tariff
          break
        end
      end

      super.tap do |h|
        h[:is_pre_contract] = true
        h[:document_name] = 'Strompreiserhöhung zum 01.01.2020'
        h[:upcoming_tariff] = build_tariff(upcoming)
      end
    end

    def template_name
      '13_tariff_change_letter.slim'
    end

  end
end
