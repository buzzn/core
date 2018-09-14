require_relative 'generator'

module Pdf
  class LocalPoolProcessingContract < Generator

    attr_reader :contract

    def initialize(contract)
      super
      @contract = contract
    end

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Abwicklungsvertrag-#{contract.localpool.slug}"
    end

    def pdf_filename
      "#{title}.pdf"
    end

    def build_struct
      {
        version: template.version,
        powergiver: build_powergiver(contract.customer),
        powertaker: build_powertaker(contract.localpool),
        number: contract.full_contract_number,
        localgroup_local_supplier: contract.localpool.distribution_system_operator,
        localgroup_additional_power_supplier: contract.localpool.electricity_supplier,
        title_text: title
      }
    end

    def build_powergiver(customer)
      {
        name: name(customer),
        partner_name: partner_name(customer),
        contact: build_contact(customer),
        address: build_address(customer.address),
        fax: customer.fax,
        phone: customer.phone,
        email: customer.email
      }
    end

    def build_contact(customer)
      {
        name: name(contact_person(customer)),
        address: build_address(contact_person(customer).address),
        fax: contact_person(customer).fax,
        phone: contact_person(customer).phone,
        email: contact_person(customer).email
      }
    end

    def build_powertaker(localpool)
      {
        address: build_address(localpool.address),
      }
    end

    def partner_name(customer)
      names = [name(legal_partner(customer))]
      if customer == Organization::GeneralResource || Organization::Base
        if !customer.additional_legal_representation.nil? || !customer.additional_legal_representation.empty?
          names += customer.additional_legal_representation.split(',').map {|x| x.strip }
        end
      end
      if names.size > 1
        names[0..names.size-2].join(', ') + " und #{names[-1]}"
      else
        names[0]
      end
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

    def contact_person(person_or_organization)
      case person_or_organization
      when PersonResource
        person_or_organization
      when Person
        person_or_organization
      when Organization::GeneralResource
        person_or_organization.contact
      when Organization::Base
        person_or_organization.contact
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
