FactoryGirl.define do
  factory :vat do
    begin_date { Date.new(2000, 1, 1) }
    amount 0.19
  end
end
