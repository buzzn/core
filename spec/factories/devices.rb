FactoryGirl.define do
  factory :device do
    manufacturer_name                 "Generic manufacturer name"
    manufacturer_product_name         "Generic product"
    manufacturer_product_serialnumber "47-11"
    mode                              "OUT"
    register                          { FactoryGirl.create(:register_input) }
    law                               "KWKG"
    category                          "Generic category"
    primary_energy                    Device::NATURAL_GAS
    watt_peak                         5500
    watt_hour_pa                      6000
    commissioning                     Date.parse("1995-01-01")
    mobile                            false
  end
end