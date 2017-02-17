module Contract
  class BaseResource < JSONAPI::Resource
    attributes  :status,
                :old_supplier_name,
                :old_customer_number,
                :old_account_number,
                :terms_accepted,
                :power_of_attorney,
                :signing_date,
                :cancellation_date,
                :begin_date,
                :end_date,
                :feedback,
                :attention_by,
                :first_master_uid,
                :second_master_uid,
                :forecast_kwh_pa,
                :metering_point_operator_name,
                :renewable_energy_law_taxation,
                :third_party_billing_number,
                :third_party_renter_number

    has_many :tariffs
    has_many :payments
    has_one :contractor
    has_one :customer
    has_one :signing_user
    has_one :address
    has_one :bank_account
  end
end
