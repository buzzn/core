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
              :retailer,
              :price_cents_per_kwh,
              :price_cents_per_month,
              :discount_cents_per_month,
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
