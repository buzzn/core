FactoryGirl.define do
  factory :billing do
    status                       :open
    begin_date                   { Date.new(2017, 1, 1) }
    end_date                     { Date.new(2017, 12, 31) }
    total_energy_consumption_kwh 2_500
    total_price_cents            { total_energy_consumption_kwh * 25.5 }
    prepayments_cents            { total_price_cents * 0.75 }
    receivables_cents            { total_price_cents * 0.25 }
  end
end
