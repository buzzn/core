require_relative '../group_resource'
require_relative '../person_resource'
require_relative '../contract/tariff_resource'
require_relative 'billing_cycle_resource'
require_relative 'device_resource'
require_relative '../../schemas/completeness/admin/localpool'

module Admin
  class LocalpoolResource < GroupResource

    include Import.args[:resource, :security_context, 'config.display_url']

    model Group::Localpool

    attributes :start_date,
               :show_object,
               :show_production,
               :show_energy,
               :show_contact,
               :show_display_app,
               :updatable, :deletable, :createables,
               :incompleteness,
               :bank_account,
               :power_sources,
               :display_app_url,
               :allowed_actions,
               # TODO remove me once the UI uses the meta data section
               :next_billing_cycle_begin_date

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :meters do |object|
      object.meters.real_or_virtual
    end
    has_many :managers, PersonResource
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :organizations
    has_many :contracts
    has_many :localpool_processing_contracts
    has_many :registers
    has_many :market_locations
    has_many :persons
    has_many :tariffs, Contract::TariffResource
    has_many :billing_cycles, BillingCycleResource, :next_billing_cycle_begin_date
    has_many :devices, DeviceResource
    has_one :owner
    has_one :gap_contract_customer
    has_one :address
    has_one :distribution_system_operator
    has_one :transmission_system_operator
    has_one :electricity_supplier
    has_one :bank_account

    # pv, chp, wind, water, etc
    def all_power_sources
      prodcution_registers = object.registers.select(:label).production
      labels = prodcution_registers.collect { |register| register.label.sub('production_', '') }
      labels.uniq
    end
    alias power_sources all_power_sources

    # absolute display app url
    def display_app_url
      if object.show_display_app
        "#{display_url}/#{object.slug}"
      end
    end

    def next_billing_cycle_begin_date
      if object.billing_cycles.empty?
        object.start_date
      else
        object.billing_cycles.order(:begin_date).last.end_date
      end
    end

    def allowed_actions
      allowed = {}
      if allowed?(permissions.metering_point_operator_contract.create)
        allowed[:create_metering_point_operator_contract] = create_metering_point_operator_contract.success? || create_metering_point_operator_contract.errors
      end
      if allowed?(permissions.localpool_processing_contracts.create)
        allowed[:create_localpool_processing_contract] = create_localpool_processing_contract.success? || create_localpool_processing_contract.errors
      end
      allowed
    end

    def create_metering_point_operator_contract
      @create_mpo ||= Schemas::PreConditions::Contract::MeteringPointOperatorCreate
      @create_mpo.call(self)
    end

    def create_localpool_processing_contract
      @create_lpc ||= Schemas::PreConditions::Contract::LocalpoolProcessingContractCreate
      @create_lpc.call(self)
    end

    def deletable
      super && object.owner.nil?
    end

  end
end
