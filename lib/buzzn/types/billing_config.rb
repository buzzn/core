require_relative '../types'

class Types::BillingConfig < Dry::Struct

  attribute :vat, Types::Coercible::Float
  attribute :vat2, Types::Coercible::Float.optional

end
