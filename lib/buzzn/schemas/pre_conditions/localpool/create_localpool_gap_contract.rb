require_relative '../localpool'
require_relative '../person'
require_relative '../organization'

module Schemas::PreConditions::Localpool

  CreateLocalpoolGapContract = Schemas::Support.Schema do
    # localpool_processing_contract is required for the generation of contract numbers
    required(:localpool_processing_contract).value(:filled?)
    required(:start_date).value(:filled?)
    required(:gap_contract_customer).value(:filled?)
  end

end
