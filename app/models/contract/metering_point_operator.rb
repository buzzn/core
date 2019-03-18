require_relative 'localpool'

module Contract
  class MeteringPointOperator < Localpool

    CONTRACT_NUMBER_BASE = 90000
    CONTRACT_NUMBER_RANGE = 10000

    def pdf_generators
      [
        Pdf::MeteringPointOperatorContract
      ]
    end

  end
end
