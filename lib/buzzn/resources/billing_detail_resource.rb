class BillingDetailResource < Buzzn::Resource::Base

  model BillingDetail

  attributes :reduced_power_amount,
             :reduced_power_factor,
             :automatic_abschlag_adjust,
             :automatic_abschlag_threshold

end
