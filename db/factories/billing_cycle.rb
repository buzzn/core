FactoryGirl.define do
  factory :billing_cycle do
    name                      { generate(:billing_cycle_name) }
    begin_date                Date.parse('2000-01-01')
    end_date                  Date.parse('2001-01-01')
    localpool                 { FactoryGirl.build(:localpool) }
  end
end
