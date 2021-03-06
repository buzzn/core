FactoryGirl.define do
  factory :price do
    name                                { generate(:price_name) }
    begin_date                          Date.parse('2016-01-01')
    energyprice_cents_per_kilowatt_hour 27.9
    baseprice_cents_per_month           300

    after(:build) do |price|
      price.localpool = FactoryGirl.create(:localpool) unless price.localpool
    end
  end
end
