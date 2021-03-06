require_relative 'localpool'

module Contract
  class LocalpoolThirdParty < Localpool

    def check_contract_number
      if self.contract_number.nil?
        self.contract_number = self.localpool.localpool_processing_contract.contract_number
      end
      self.check_contract_number_addition
    end

  end
end
