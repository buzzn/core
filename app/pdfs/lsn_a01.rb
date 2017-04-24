module Buzzn::Pdfs
  class LSN_A01 < PdfGenerator

    TEMPLATE = 'lsn_a01.slim'

    def initialize(contract)
      super({a: 123})
      @contract = contract
    end
  end
end
