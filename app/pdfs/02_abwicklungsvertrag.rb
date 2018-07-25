require_relative 'generator'

module Pdf
  class LocalPoolProcessingContract < Generator

    attr_reader :contract

    def initialize(contract)
      super
      @contract = contract
    end

    protected

    def build_struct
      {
        version: template.version,
        powergiver: build_powergiver(contract.customer),
        powertaker: build_powertaker(contract.localpool),
        number: contract.full_contract_number
      }
    end

    def build_powergiver(customer)
      {
        name: name(customer),
        partner_name: name(legal_partner(customer)),
        address: build_address(customer.address),
        fax: customer.fax,
        phone: customer.phone,
        email: customer.email
      }
    end

    def build_powertaker(localpool)
      {
        address: build_address(localpool.address),
      }
    end

    def name(person_or_organization)
      case person_or_organization
      when PersonResource
        person_or_organization.first_name + ' ' + person_or_organization.last_name
      when Person
        person_or_organization.first_name + ' ' + person_or_organization.last_name
      when Organization::GeneralResource
        person_or_organization.name
      when Organization::Base
        person_or_organization.name
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def legal_partner(person_or_organization)
      case person_or_organization
      when PersonResource
        person_or_organization
      when Person
        person_or_organization
      when Organization::GeneralResource
        person_or_organization.legal_representation
      when Organization::Base
        person_or_organization.legal_representation
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def build_address(address)
      {
        street: address.street,
        zip: address.zip,
        city: address.city
      }
    end

  end
end
