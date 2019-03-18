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

    CONTRACT_NUMBER_BASE = 60000
    CONTRACT_NUMBER_RANGE = 10000

    def pdf_generators
      [
        Pdf::LocalpoolProcessingContract
      ]
    end

  end
end
