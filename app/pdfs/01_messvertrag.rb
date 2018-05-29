require_relative 'pdf_generator'

module Pdf
  class MeteringPointOperator < Generator

    def initialize(contract)
      super
      @contract = contract
    end

    protected

    def build_struct
      {
        version: template.version,
        customer: build_customer(contract.localpool.owner),
        address: build_address(contract.localpool.address),
        number: contract.full_contract_number,
      }
    end

    private

    def name(person_or_organization)
      case person_or_organization
      when Person
        person_or_organization.first_name + ' ' + person_or_organization.last_name
      when Organization
        person_or_organization.name
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def contract
      @contract
    end

    def build_customer(customer)
      partner = legal_partner(customer)
      {
        name: name(customer),
        partner_name: name(partner),
        partner: build_person(partner),
        address: build_address(customer.address)
      }
    end

    def build_person(person)
      {
        name: person.name,
        phone: person.phone,
        fax: person.fax,
        email: person.email
      }
    end

    def legal_partner(person_or_organization)
      case person_or_organization
      when Person
        person_or_organization
      when Organization
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
