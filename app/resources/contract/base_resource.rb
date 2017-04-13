module Contract
  class BaseResource < Buzzn::EntityResource

    abstract

    model Base

    attributes  :status,
                :contract_number,
                :customer_number,
                :signing_date,
                :cancellation_date,
                :end_date

    attributes :updatable, :deletable

    has_many :tariffs
    has_many :payments
    has_one :contractor
    has_one :customer
    has_one :signing_user
    has_one :bank_account

    alias :contractor_raw! :contractor!
    def contractor!
      ContractingPartyResource.new(contractor_raw!.object)
    end

    alias :customer_raw! :customer!
    def customer!
      # FIXME use customer_raw! as it comes with permission check
      #       this here skips the permission check
      ContractingPartyResource.new(object.customer)
    end
  end
end
