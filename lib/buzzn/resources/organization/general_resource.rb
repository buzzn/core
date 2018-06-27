require_relative 'base_resource'

module Organization
  class GeneralResource < BaseResource

    model Organization::General

    attributes :customer_number

    has_one :contact
    has_one :legal_representation
    has_many :bank_accounts

    def type
      'organization'
    end

    def customer_number
      object.customer_number&.id
    end

  end
end
