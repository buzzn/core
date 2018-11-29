module Contract
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes  :full_contract_number,
                :signing_date,
                :begin_date,
                :termination_date,
                :end_date,
                :last_date,
                :status

    attributes :updatable, :deletable, :documentable

    has_many :tariffs
    has_many :payments
    has_many :documents
    has_one :contractor
    has_one :customer
    has_one :customer_bank_account
    has_one :contractor_bank_account

    def documentable
      !permissions.nil? && allowed?(permissions.document)
    end
    alias documentable? documentable

  end
end
