module Buzzn::Validation
  module Predicates
    include Dry::Logic::Predicates

    
    predicate(:iban?) do |value|
      IBANTools::IBAN.valid?(value)
    end

    predicate(:email?) do |value|
      ! URI::MailTo::EMAIL_REGEXP.match(value).nil?
    end

    predicate(:uuid?) do |value|
      ! URI::MailTo::EMAIL_REGEXP.match(value).nil?
    end

    predicate(:phone_number?) do |value|
      ! /^[()+\s0-9]*$/.match(value).nil?
    end
  end
end
