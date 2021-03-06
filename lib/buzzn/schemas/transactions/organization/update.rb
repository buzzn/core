require './app/models/organization/general.rb'
require './app/models/organization/market.rb'
require_relative '../organization'
require_relative '../address/create'
require_relative '../address/update'
require_relative '../person/create'
require_relative '../person/update'

module Schemas::Transactions

  module Organization

    Update = Schemas::Support.Form(Schemas::Transactions::Update) do
      optional(:name).filled(:str?, max_size?: 64, min_size?: 4)
      optional(:description).maybe(:filled?, :str?, max_size?: 256)
      optional(:email).maybe(:filled?, :str?, :email?, max_size?: 64)
      optional(:phone).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
      optional(:fax).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
      optional(:website).maybe(:filled?, :str?, :url?, max_size?: 64)
      optional(:additional_legal_representation).maybe(:str?, max_size?: 256)
    end

    UpdateMarket = Schemas::Support.Form(Schemas::Transactions::Update) do
      optional(:name).filled(:str?, max_size?: 64, min_size?: 4)
      optional(:description).maybe(:str?, max_size?: 256)
      optional(:email).maybe(:str?, :email?, max_size?: 64)
      optional(:phone).maybe(:str?, :phone_number?, max_size?: 64)
      optional(:fax).maybe(:str?, :phone_number?, max_size?: 64)
      optional(:website).maybe(:str?, :url?, max_size?: 64)
    end

    class << self

      def update_for(resource)
        key = accept(KeyVisitor.new, resource)
        if schema = cache[key]
          schema
        else
          visitor = case resource
                    when ::Organization::GeneralResource, ::Organization::General
                      SchemaVisitor.new(Update)
                    when ::Organization::MarketResource, ::Organization::Market
                      SchemaVisitor.new(UpdateMarket)
                    end
          cache[key] = accept(visitor, resource)
        end
      end

      private

      def cache
        @cache ||= Array.new(32)
      end

      def accept(visitor, resource)
        case resource
        when ::Organization::GeneralResource, ::Organization::General
          visitor.address(!resource.address.nil?)
          visitor.legal(!resource.legal_representation.nil?)
          visitor.legal_address(!resource&.legal_representation&.address.nil?)
          visitor.contact(!resource&.contact.nil?)
          visitor.contact_address(!resource&.contact&.address.nil?)
        when ::Organization::MarketResource, ::Organization::Market
          visitor.address(!resource.address.nil?)
        end
        visitor.result
      end

    end

  end

  class SchemaVisitor

    def initialize(schema)
      @schema = schema
    end

    def result
      @schema
    end

    def address(yes)
      if yes
        @schema = Schemas::Support.Form(@schema) do
          optional(:address).schema(Address::Update)
        end
      else
        @schema = Schemas::Support.Form(@schema) do
          optional(:address).schema(Address::Create)
        end
      end
    end

    def legal(yes)
      @has_legal = yes
      do_person('legal', :legal_representation) unless @has_legal_address.nil?
    end

    def legal_address(yes)
      @has_legal_address = yes
      do_person('legal', :legal_representation) unless @has_legal.nil?
    end

    def contact(yes)
      @has_contact = yes
      do_person('contact', :contact) unless @has_contact_address.nil?
    end

    def contact_address(yes)
      @has_contact_address = yes
      do_person('contact', :contact) unless @has_contact.nil?
    end

    private

    def do_person(method, param)
      @schema =
        if instance_variable_get("@has_#{method}")
          if instance_variable_get("@has_#{method}_address")
            Schemas::Support.Form(@schema) do
              optional(param).schema(Person.assign_or_update_with_address)
            end
          else
            Schemas::Support.Form(@schema) do
              optional(param).schema(Person.assign_or_update_without_address)
            end
          end
        else
          Schemas::Support.Form(@schema) do
            optional(param).schema(Person::AssignOrCreateWithAddressOptional)
          end
        end
    end

  end

  class KeyVisitor

    NONE = 0
    ADDRESS = 1
    LEGAL = 2
    LEGAL_ADDRESS = 4
    CONTACT = 8
    CONTACT_ADDRESS = 16

    def initialize
      @key = NONE
    end

    def result
      @key
    end

    def address(yes)
      if yes
        @key |= ADDRESS
      end
    end

    def legal(yes)
      if yes
        @key |= LEGAL
      end
    end

    def legal_address(yes)
      if yes
        @key |= LEGAL_ADDRESS
      end
    end

    def contact(yes)
      if yes
        @key |= CONTACT
      end
    end

    def contact_address(yes)
      if yes
        @key |= CONTACT_ADDRESS
      end
    end

  end

end
