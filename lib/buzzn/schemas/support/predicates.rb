require_relative '../support'
require 'ruby_regex'
require 'iban-tools'

module Schemas::Support::Predicates

  include Dry::Logic::Predicates

  predicate(:id?) do |value|
    value.is_a?(Hash) && value.key?(:id)
  end

  predicate(:bigint?) do |value|
    # FIXME alias this to :int? of dry::types
    begin
      Integer(value)
      true
    rescue ArgumentError
      false
    end
  end

  predicate(:id_and_not_updated_at?) do |value|
    value.is_a?(Hash) && value.key?(:id) && !value.key?(:updated_at)
  end

  predicate(:not_id_and_updated_at?) do |value|
    value.is_a?(Hash) && !value.key?(:id) && value.key?(:updated_at)
  end

  predicate(:not_id_and_not_updated_at?) do |value|
    value.is_a?(Hash) && !value.key?(:id) && !value.key?(:updated_at)
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
    url_protocol_optional = /(\A\z)|(\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z)/ix
    ! url_protocol_optional.match(value).nil?
  end

  predicate(:phone_number?) do |value|
    ! /^[0-9+\(\)#\.\s\/ext-]+$/.match(value).nil?
  end

  predicate(:mtype?) do |type, validator|
    validator.model_is_a?(type)
  end

  predicate(:alphanumeric?) do |value|
    ! /^[a-zA-Z0-9]+$/.match(value).nil?
  end

  predicate(:unique_begin_date?) do |value|
    # count all begin_date, if there are duplicate begin_dates
    value.inject(Hash.new(0)) {|h,i| h[i.begin_date] += 1; h }.keep_if{|k,v| v > 1}.empty?
  end

  predicate(:covers_beginning?) do |begin_date, items|
    first = items.min_by(&:begin_date)
    !(first.nil? || first.begin_date > begin_date)
  end

end
