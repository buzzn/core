require 'buzzn/schemas/contract_invariants'
module Contract
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes  :full_contract_number,
                :customer_number,
                :signing_date,
                :begin_date,
                :termination_date,
                :end_date,
                :status

    attributes :updatable, :deletable

    has_many :tariffs
    has_many :payments
    has_one :contractor
    has_one :customer
    has_one :customer_bank_account
    has_one :contractor_bank_account

    def invariants
      ContractInvariants.(self)
    end
  end
end
