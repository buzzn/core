FactoryGirl.define do
  # Please keep sequences ordered alphabetically
  sequence(:localpool_name)       { |i| "Localpool #{i}"  }
  sequence(:metering_point_id)    { |i| "DE" + (i + 26917588246326615503884000).to_s }
  sequence(:meter_serial_number)  { |i| i + 65640000 }
  sequence(:mpo_contract_number)  { |i| i + 90_000 }
  sequence(:organization_name)    { |i| "Generic organization #{i}" }
  sequence(:person_image)         { |i| name = (i % 60) + 1; "#{name}.jpg" }
  sequence(:powertaker_email)     { |i| "dev+pt#{i}@buzzn.net" }
  sequence(:powertaker_last_name) { |i| "Powertaker #{i}" }
  sequence(:price_name)           { |i| "Generic price #{i}" }
  sequence(:register_uid)         { |i| i + 90688251510000000000002677000 }
  sequence(:register_input_name)  { |i| "Wohnung #{i}" }
  sequence(:register_output_name) { |i| "Output #{i}" }
  sequence(:tariff_name)          { |i| "Generic tariff #{i}" }
end