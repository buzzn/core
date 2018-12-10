require_relative 'localpool_resource'
require_relative '../register/meta_resource'

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
                :mandate_reference,
                :confirm_pricing_model,
                :power_of_attorney,
                :other_contract,
                :move_in,
                :authorization,
                :original_signing_user,
                :metering_point_operator_name,
                :share_register_with_group,
                :share_register_publicly

    has_one :register_meta, Register::MetaResource
    has_many :billings, Admin::BillingResource

    def share_register_with_group
      object.register_meta_option.nil? ? false : object.register_meta_option.share_with_group
    end

    def share_register_publicly
      object.register_meta_option.nil? ? false : object.register_meta_option.share_publicly
    end

  end
end
