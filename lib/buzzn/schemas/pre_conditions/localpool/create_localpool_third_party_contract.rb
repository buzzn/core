require_relative '../localpool'

module Schemas::PreConditions::Localpool

  CreateLocalpoolThirdPartyContract = Schemas::Support.Schema do
    required(:localpool_processing_contract).value(:filled?)
  end

end
