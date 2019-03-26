require_relative 'localpool'

module Contract
  class LocalpoolProcessing < Localpool

    CONTRACT_NUMBER_BASE = 60000
    CONTRACT_NUMBER_RANGE = 10000

    def pdf_generators
      [
        Pdf::LocalpoolProcessingContract
      ]
    end

  end
end
