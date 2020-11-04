require_relative 'a0x_general'
require_relative 'tariff_change_letter_general'

module Pdf
  class TariffChangeLetter < TariffChangeLetterGeneral
    def template_name
      '13_tariff_change_letter.slim'
    end
  end
end
