require_relative 'a0x_general'
require_relative 'tariff_change_letter_general'

module Pdf
  class TariffChangeLetterIsarwatt < TariffChangeLetterGeneral
    def template_name
      '14_tariff_change_letter_isarwatt.slim'
    end
  end
end
