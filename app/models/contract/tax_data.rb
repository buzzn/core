module Contract
  class TaxData < ActiveRecord::Base
    self.table_name = :contract_tax_data

    belongs_to :contract, class_name: 'LocalpoolProcessing', foreign_key: :contract_id
  end
end
