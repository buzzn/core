module Contract
  class BaseSerializer < ActiveModel::Serializer

    attributes  :status,
                :contract_number,
                :customer_number,
                :signing_date,
                :cancellation_date,
                :end_date
                
    has_many :tariffs
    has_many :payments
    has_one :contractor
    has_one :customer
    has_one :signing_user
    has_one :address
    has_one :bank_account
  end
end
