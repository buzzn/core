class ContractingPartyResource < ApplicationResource

  attributes  :legal_entity,
              :sales_tax_number,
              :tax_rate,
              :tax_number

  has_one :address
  has_one :bank_account
end
