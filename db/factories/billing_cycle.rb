FactoryGirl.define do
  factory :billing_cycle, class: 'BillingCycle' do
    name                      { generate(:billing_cycle_name) }
    begin_date                Date.parse('2000-01-01')
    end_date                  Date.parse('2001-01-01')

    after(:build) do |cycle|
      cycle.localpool = FactoryGirl.build(:localpool) unless cycle.localpool
    end
  end
end
