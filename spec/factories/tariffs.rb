FactoryGirl.define do
  factory :tariff, class: 'Contract::Tariff' do
    sequence(:name)           { |i| "Generic tariff #{i + 1}" }
    begin_date                Date.parse("2000-01-01")
    energyprice_cents_per_kwh 27.9
    baseprice_cents_per_month 300
    contracts                 { FactoryGirl.create(:contract) }
  end
end