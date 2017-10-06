FactoryGirl.define do
  # Please keep sequences ordered alphabetically
  sequence(:localpool_name)      { |i| "Localpool #{i}"  }
  sequence(:metering_point_id)   { |i| "DE26917588246326615503884372" + sprintf("%03d", i) }
  sequence(:meter_serial_number) { |i| "6564" + sprintf("%04d", i) }
  sequence(:mpo_contract_number) { |i| i + 90_012 }
  sequence(:organization_name)   { |i| "Generic organization #{i}" }
  sequence(:price_name)          { |i| "Generic price #{i}" }
  sequence(:register_uid)        { |i| i + 90688251510000000000002677114 }
  sequence(:register_input_name) { |i| "Wohnung #{i}" }
  sequence(:tariff_name)         { |i| "Generic tariff #{i + 1}" }
end