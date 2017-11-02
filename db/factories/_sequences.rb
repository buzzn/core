FactoryGirl.define do
  # Please keep sequences ordered alphabetically
  sequence(:localpool_name)                      { |i| "Localpool #{i}"  }
  sequence(:localpool_power_taker_contract_nr)   { |i| i + 60_000 }
  sequence(:market_partner_id)                   { |i| i + 9_911_845_999_000 }
  sequence(:metering_point_id)                   { |i| "DE" + (i + 26917588246326615503884_000).to_s }
  sequence(:meter_serial_number)                 { |i| i + 65640_000 }
  sequence(:metering_point_operator_contract_nr) { |i| i + 90_000 }
  sequence(:organization_name)                   { |i| "Generic organization #{i}" }
  sequence(:person_image)                        { |i| name = (i % 30) + 1; "#{name}.jpg" }
  sequence(:power_giver_contract_nr)             { |i| i + 40_000 }
  sequence(:power_taker_contract_nr)             { |i| i + 20_000 }
  sequence(:localpool_processing_contract_nr)    { |i| i + 10_000 }
  sequence(:powertaker_email)                    { |i| "dev+pt#{i}@buzzn.net" }
  sequence(:powertaker_last_name)                { |i| "Powertaker #{i}" }
  sequence(:price_name)                          { |i| "Generic price #{i}" }
  sequence(:register_uid)                        { |i| i + 90688251510000000000002677_000 }
  sequence(:register_input_name)                 { |i| "Wohnung #{i}" }
  sequence(:register_output_name)                { |i| "Output #{i}" }
  sequence(:tariff_name)                         { |i| "Generic tariff #{i}" }
  sequence(:edifact_email)                       { |i| "dev+edifact#{i}@buzzn.net" }
end
