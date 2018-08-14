require_relative '../support'
require 'ruby_regex'

module Schemas::Support::Predicates

  include Dry::Logic::Predicates

  predicate(:id?) do |value|
    value.is_a?(Hash) && value.key?(:id)
  end

  predicate(:iban?) do |value|
    IBANTools::IBAN.valid?(value)
  end

  predicate(:email?) do |value|
    ! URI::MailTo::EMAIL_REGEXP.match(value).nil?
  end

  predicate(:uid?) do |value|
    ! RubyRegex::UUID.match(value).nil?
  end

  predicate(:url?) do |value|
    # loosen for now
    # ! RubyRegex::URL.match(value).nil?
    URL_PROTOCOL_OPTIONAL = /(\A\z)|(\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z)/ix
    ! URL_PROTOCOL_OPTIONAL.match(value).nil?
  end

  predicate(:phone_number?) do |value|
    ! /^[0-9+\(\)#\.\s\/ext-]+$/.match(value).nil?
  end

  predicate(:mtype?) do |type, validator|
    validator.model_is_a?(type)
  end

end
