class BillingDetailResource < Buzzn::Resource::Entity

  model BillingDetail

  attributes :reduced_power_amount,
             :reduced_power_factor,
             :automatic_abschlag_adjust,
             :automatic_abschlag_threshold_cents,
             :issues_vat

end
