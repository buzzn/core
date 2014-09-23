json.array!(@servicing_contracts) do |servicing_contract|
  json.extract! servicing_contract, :id, :tariff, :status, :signing_user, :terms, :confirm_pricing_model, :power_of_attorney, :commissioning, :termination, :forecast_watt_hour_pa, :price_cents
  json.url servicing_contract_url(servicing_contract, format: :json)
end
