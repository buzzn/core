FactoryGirl.define do
  factory :billing_detail do
    issues_vat false
    reduced_power_amount 137.0
    reduced_power_factor 0.24
    automatic_abschlag_adjust false
    automatic_abschlag_threshold_cents 0
  end
end
