require_relative 'localpool'

module Contract
  class LocalpoolProcessing < Localpool

    has_one :tax_data, class_name: 'Contract::TaxData', foreign_key: :contract_id
    delegate :subject_to_tax,
             :sales_tax_number,
             :tax_number,
             :tax_rate,
             :creditor_identification,
             :retailer,
             :provider_permission,
             to: :tax_data, allow_nil: true

    before_save :check_contract_number
    before_create :check_contract_number

    private

    CONTRACT_NUMBER_BASE = 60000
    CONTRACT_NUMBER_RANGE = 10000

    def check_contract_number
      if self.contract_number.nil?
        maximum = self.class.maximum(:contract_number)
        if maximum.nil? || (maximum < CONTRACT_NUMBER_BASE || maximum > CONTRACT_NUMBER_BASE+CONTRACT_NUMBER_RANGE-1)
          self.contract_number = CONTRACT_NUMBER_BASE
        else
          self.contract_number = maximum + 1
        end
      end
      if self.contract_number_addition.nil?
        self.contract_number_addition = (self.class.where(:contract_number => self.contract_number).maximum(:contract_number_addition) || -1) + 1
      end
    end

  end
end
