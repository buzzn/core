FactoryGirl.define do
  factory :device do
    manufacturer_name                 "Generic manufacturer name"
    manufacturer_product_name         "Generic product"
    manufacturer_product_serialnumber "47-11"
    mode                              "OUT"
    register                          { FactoryGirl.create(:register, :input) }
    law                               "KWKG"
    category                          "Generic category"
    primary_energy                    Device::NATURAL_GAS
    watt_peak                         5_500
    watt_hour_pa                      6_000
    commissioning                     Date.parse("1995-01-01")
    mobile                            false

    trait :bhkw do
      manufacturer_name 'Senertec'
      manufacturer_product_name 'Dachs'
      manufacturer_product_serialnumber '453454-K-45645'
      law 'KWKG'
      category 'Blockheizkraftwerk'
      primary_energy Device::NATURAL_GAS
      watt_peak 5_500
      watt_hour_pa 6000
    end

    trait :pv do
      manufacturer_name 'Solarex'
      manufacturer_product_name 'MX-64'
      manufacturer_product_serialnumber '446.436.124'
      law 'EEG'
      category 'Photovoltaikanlage'
      primary_energy Device::SUN
      watt_peak 2_160
      watt_hour_pa 2_200
    end

    trait :ecar do
      manufacturer_name 'Mitsubishi'
      manufacturer_product_name 'i-MiEV'
      manufacturer_product_serialnumber 'VIN23233'
      mode 'IN'
      law 'n/a'
      category 'eMobilität'
      primary_energy Device::OTHER
      watt_peak 49_000
    end
  end
end
