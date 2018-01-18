require_relative 'base_resource'
require_relative '../group_resource'

module Contract
  class LocalpoolPowerTakerResource < BaseResource

    model LocalpoolPowerTaker

    attributes  :forecast_kwh_pa,
                :renewable_energy_law_taxation,
                :third_party_billing_number,
                :third_party_renter_number,
                :old_supplier_name,
                :old_customer_number,
                :old_account_number,
                :mandate_reference

    has_one :register
    has_one :localpool, GroupResource
  end
end
