FactoryGirl.define do
  factory :billing_brick do
    billing { FactoryGirl.build(:billing) }
    # can't set this dependent on the billing ... need to investigate
    # begin_date { billing.begin_date }
    # end_date   { billing.end_date }
  end
end
