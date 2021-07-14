class BillingDetail < ActiveRecord::Base

  has_one :group

  def self.defaults
    {
      issues_vat: false,
      leg_single: false,
      reduced_power_amount: 0,
      reduced_power_factor: 0,
      automatic_abschlag_adjust: false,
      automatic_abschlag_threshold_cents: 500,
    }
  end

end
