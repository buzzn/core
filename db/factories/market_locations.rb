FactoryGirl.define do
  factory :market_location do
    name '1.OG links vorne'
    group { FactoryGirl.create(:localpool) }
  end
end
