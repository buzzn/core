require_relative 'localpool_resource'

module Contract
  class LocalpoolPowerTakerResource < LocalpoolResource

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

  end
end
