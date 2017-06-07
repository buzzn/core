module Buzzn::Validation
  module Predicates
    include Dry::Logic::Predicates

    
    predicate(:iban?) do |value|
      IBANTools::IBAN.valid?(value)
    end
  end
end
