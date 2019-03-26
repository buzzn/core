require_relative 'base'

module Contract
  class Localpool < Base

    # NOTE: having this in breaks the factories as type is not getting set.
    #self.abstract_class = true

    belongs_to :localpool, class_name: 'Group::Localpool'
    has_one :tax_data, class_name: 'Contract::TaxData', foreign_key: :contract_id
    delegate :subject_to_tax,
             :sales_tax_number,
             :tax_number,
             :tax_rate,
             :creditor_identification,
             :retailer,
             :provider_permission,
             to: :tax_data, allow_nil: true

    # abstract

    CONTRACT_NUMBER_BASE = -1
    CONTRACT_NUMBER_RANGE = -1

    def check_contract_number_addition
      if self.contract_number_addition.nil?
        self.contract_number_addition = (Contract::Localpool.where(:contract_number => self.contract_number).maximum(:contract_number_addition) || -1) + 1
      end
    end

    def check_contract_number
      if self.contract_number.nil?
        # abstract check
        if self.class::CONTRACT_NUMBER_BASE.negative? || self.class::CONTRACT_NUMBER_RANGE.negative?
          raise 'CONTRACT_NUMBER_? must be set to a valid number'
        end

        maximum = self.class.maximum(:contract_number)
        if maximum.nil? || (maximum < self.class::CONTRACT_NUMBER_BASE || maximum > self.class::CONTRACT_NUMBER_BASE+self.class::CONTRACT_NUMBER_RANGE-1)
          self.contract_number = self.class::CONTRACT_NUMBER_BASE
        else
          self.contract_number = maximum + 1
        end
      end
      self.check_contract_number_addition
    end

  end
end
