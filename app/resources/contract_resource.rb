class ContractResource < ApplicationResource

  attributes  :status,
              :customer_number,
              :contract_number,
              :signing_user,
              :terms,
              :power_of_attorney,
              :confirm_pricing_model,
              :commissioning,
              :other_contract,
              :move_in,
              :beginning,
              :authorization,
              :feedback,
              :attention_by,
              :mode

  has_one :address
  has_one :bank_account
end
