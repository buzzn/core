require './app/models/organization.rb'
require_relative '../organization'
require_relative '../address/create'
require_relative '../address/update'
require_relative '../person/create'
require_relative '../person/update'

module Schemas::Transactions

  Organization::Update = Schemas::Support.Form(Update) do
    optional(:name).filled(:str?, max_size?: 64, min_size?: 4)
    optional(:description).filled(:str?, max_size?: 256)
    optional(:email).filled(:str?, :email?, max_size?: 64)
    optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
    optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
    optional(:website).filled(:str?, :url?, max_size?: 64)
  end

  def update_for(resource)
    key = accept(KeyVisitor.new, resource)
    if schema = cache[key]
      schema
    else
      cache[key] = accept(SchemaVisitor.new(Update), resource)
    end
  end

  private

  def cache
    @cache ||= Array.new(16) # only 12 are used but easier to have holes
  end

  def accept(visitor, resource)
    visitor.address(!resource.address.nil?)
    visitor.legal(!resource.legal_representation.nil?)
    visitor.contact_address(!resource&.contact&.address.nil?)
    visitor.contact(!contact.nil?)
    visitor.result
  end

  class SchemaVisitor

    def initialize(schema)
      @schema = schema
    end

    def result
      @schema
    end

    def address(yes)
      @schema = Schemas::Support.Form(@schema) do
        optional(:address).schema(yes ? Address::Update : Address::Create)
      end
    end

    def legal(yes)
      @schema = Schemas::Support.Form(@schema) do
        optional(:address).schema(yes ? Person::Update : Person::Create)
      end
    end

    def contact(yes)
      @has_contact = yes
      do_contact unless @has_contact_address.nil?
    end

    def contact_address(yes)
      @has_contact_address = yes
      do_contact unless @has_contact.nil?
    end

    private

    def do_contact
      @schema = Schemas::Support.Form(@schema) do
        if @has_contact
          if @has_contact_address
            optional(:contact).schema(Person::Update.update_with_address)
          else
            optional(:contact).schema(Person::Update.update_without_address)
          end
        else
          optional(:contact).schema(Person::CreateWithAddress)
        end
      end
    end

  end

  class KeyVisitor

    NONE = 0
    ADDRESS = 1
    LEGAL = 2
    CONTACT = 4
    CONTACT_ADDRESS = 8

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