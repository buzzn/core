require_relative '../support'

module Schemas::Support::Predicates

  include Dry::Logic::Predicates

  predicate(:iban?) do |value|
    IBANTools::IBAN.valid?(value)
  end

  predicate(:email?) do |value|
    ! URI::MailTo::EMAIL_REGEXP.match(value).nil?
  end

  predicate(:uuid?) do |value|
    ! RubyRegex::UUID.match(value).nil?
  end

  predicate(:url?) do |value|
    ! RubyRegex::URL.match(value).nil?
  end

  predicate(:phone_number?) do |value|
    ! /^[0-9+\(\)#\.\s\/ext-]+$/.match(value).nil?
  end

end
