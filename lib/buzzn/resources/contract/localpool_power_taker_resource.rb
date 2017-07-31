module Contract
  class LocalpoolPowerTakerResource < BaseResource

    model LocalpoolPowerTaker

    attributes  :begin_date,
                :forecast_kwh_pa,
                :renewable_energy_law_taxation,
                :third_party_billing_number,
                :third_party_renter_number,
                :old_supplier_name,
                :old_customer_number,
                :old_account_number
    
    has_one :register
  end
end
