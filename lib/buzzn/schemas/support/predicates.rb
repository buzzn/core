module Buzzn
  module Schemas
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
        ! /^[0-9+\(\)#\.\s\/ext-]+$/.match(value).nil?
      end
    end
  end
end
