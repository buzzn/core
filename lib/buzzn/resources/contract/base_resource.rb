require_relative '../contracting_party_resource'
module Contract
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes  :status,
                :full_contract_number,
                :customer_number,
                :signing_user,
                :signing_date,
                :cancellation_date,
                :end_date

    attributes :updatable, :deletable

    has_many :tariffs
    has_many :payments
    has_one :contractor, ContractingPartyResource
    has_one :customer, ContractingPartyResource
    has_one :customer_bank_account
    has_one :contractor_bank_account
  end
end
