require_relative 'generator'
require_relative 'serializers'

module Pdf
  class LocalPoolProcessingContract < Generator

    include Serializers

    attr_reader :contract

    def initialize(contract)
      super
      @contract = contract
    end

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Abwicklungsvertrag-#{contract.localpool.slug}"
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

  end
end
