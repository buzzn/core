FactoryGirl.define do
  factory :tariff, class: 'Contract::Tariff' do
    name                      { generate(:tariff_name) }
    begin_date                Date.parse("2000-01-01")
    energyprice_cents_per_kwh 27.9
    baseprice_cents_per_month 300

    after(:build) do |tariff|
      tariff.group = FactoryGirl.build(:localpool) unless tariff.group
      tariff.contracts << FactoryGirl.build(:contract, localpool: tariff.group) if tariff.contracts.empty?
    end
  end
end
