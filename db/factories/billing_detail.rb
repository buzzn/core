FactoryGirl.define do
  factory :billing_detail do
    reduced_power_amount 137.0
    reduced_power_factor 0.24
    automatic_abschlag_adjust false
    automatic_abschlag_threshold 0
  end
end
