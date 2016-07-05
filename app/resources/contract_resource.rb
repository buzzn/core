class ContractResource < ApplicationResource

  attributes  :tariff,
              :status,
              :customer_number,
              :contract_number,
              :signing_user,
              :terms,
              :power_of_attorney,
              :confirm_pricing_model,
              :commissioning,
              :mode,
              :updateable, :deletable

  has_one :address
  has_one :bank_account
end
