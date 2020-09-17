require_relative '../contract'

Schemas::PreConditions::Contract::Delete = Schemas::Support.Schema do

  configure do
    def no_billing_for_gap_contract_to_be_deleted?(billings)
      # reject all open and void billings, if some are
      # left that means that this reading is used
      # in billings that are beyond 'calculated'
      billings.empty?
    end

    def contract_to_be_deleted_gap_contract?(type)
      type == "Contract::LocalpoolGap"
    end
  end

  optional(:billings).maybe
  required(:type).filled
  

  rule(billings: [:billings]) do |billings|
    billings.no_billing_for_gap_contract_to_be_deleted?
  end


  rule(contract: [:type]) do |type|
    type.contract_to_be_deleted_gap_contract?
  end
end