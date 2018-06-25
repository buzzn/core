FactoryGirl.define do
  factory :device do
    manufacturer                      'Generic manufacturer name'
    localpool                         { FactoryGirl.create(:group, :localpool) }
    law                               Device.laws[:kwkg]
    # category                          'Generic category'
    primary_energy                    Device.primary_energies[:natural_gas]
    watt_peak                         5_500
    watt_hour_pa                      6_000
    commissioning                     Date.parse('1995-01-01')

    trait :bhkw do
      manufacturer 'Senertec'
      #manufacturer_product_name 'Dachs'
      #manufacturer_product_serialnumber '453454-K-45645'
      law Device.laws[:kwkg]
      #category 'Blockheizkraftwerk'
      primary_energy Device.primary_energies[:natural_gas]
      watt_peak 5_500
      watt_hour_pa 6000
    end

    trait :pv do
      manufacturer 'Solarex'
      #manufacturer_product_name 'MX-64'
      #manufacturer_product_serialnumber '446.436.124'
      law Device.laws[:eeg]
      #category 'Photovoltaikanlage'
      primary_energy Device.primary_energies[:sun]
      watt_peak 2_160
      watt_hour_pa 2_200
    end

    trait :ecar do
      manufacturer 'Mitsubishi'
      #manufacturer_product_name 'i-MiEV'
      #manufacturer_product_serialnumber 'VIN23233'
      law nil
      #category 'eMobilität'
      primary_energy Device.primary_energies[:other]
      watt_peak 49_000
    end
  end
end
