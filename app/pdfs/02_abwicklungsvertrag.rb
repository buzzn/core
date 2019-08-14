require_relative 'generator'
require_relative 'serializers'

module Pdf
  class LocalpoolProcessingContract < Generator

    include Serializers

    attr_reader :contract

    def initialize(contract)
      super
      @contract = contract
    end

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Abwicklungsvertrag-#{contract.localpool.base_slug}"
    end

    def build_struct
      {
        version: template.version,
        powergiver: build_powergiver(contract.customer, contract),
        powertaker: build_powertaker(contract.localpool),
        number: contract.full_contract_number,
        localgroup_local_supplier: contract.localpool.distribution_system_operator,
        localgroup_additional_power_supplier: contract.localpool.electricity_supplier,
        title_text: title
      }
    end

    # TODO rename, collision/overwrite from Serializers
    def build_powertaker(localpool)
      {
        address: build_address(localpool.address),
      }
    end

  end
end
