require_relative '../types'

class Types::BillingConfig < Dry::Struct

  attribute :vat, Types::Coercible::Float

end
