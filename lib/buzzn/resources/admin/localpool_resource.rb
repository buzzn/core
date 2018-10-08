require_relative '../group_resource'
require_relative '../person_resource'
require_relative '../contract/tariff_resource'
require_relative '../register/meta_resource'
require_relative '../meter/real_resource'
require_relative '../meter/virtual_resource'
require_relative '../contract/localpool_processing_resource'
require_relative '../contract/localpool_power_taker_resource'
require_relative '../contract/localpool_third_party_resource'
require_relative '../contract/metering_point_operator_resource'
require_relative '../billing_detail_resource'
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
               :legacy_power_giver_contract_buzznid,
               :legacy_power_taker_contract_buzznid,
               # TODO remove me once the UI uses the meta data section
               :next_billing_cycle_begin_date

    has_many :meters do |object|
      object.meters.real_or_virtual
    end
    has_many :meters_real, Meter::RealResource
    has_many :meters_virtual, Meter::VirtualResource
    has_many :managers, PersonResource
    has_many :users
    has_many :organizations

    has_many :contracts
    has_many :localpool_processing_contracts, Contract::LocalpoolProcessingResource
    has_many :metering_point_operator_contracts, Contract::MeteringPointOperatorResource
    has_many :localpool_power_taker_contracts, Contract::LocalpoolPowerTakerResource
    has_many :localpool_third_party_contracts, Contract::LocalpoolThirdPartyResource

    has_many :registers
    has_many :market_locations, Register::MetaResource do |object|
      object.register_meta
    end
    has_many :register_meta
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
    has_one :billing_detail, BillingDetailResource

    # pv, chp, wind, water, etc
    def all_power_sources
      prodcution_registers = object.registers.production.includes(:meta)
      labels = prodcution_registers.collect { |register| register.meta.label.sub('production_', '') }
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
      if allowed?(permissions.metering_point_operator_contracts.create)
        allowed[:create_metering_point_operator_contract] = create_metering_point_operator_contract.success? || create_metering_point_operator_contract.errors
      end
      if allowed?(permissions.localpool_processing_contracts.create)
        allowed[:create_localpool_processing_contract] = create_localpool_processing_contract.success? || create_localpool_processing_contract.errors
      end
      if allowed?(permissions.localpool_power_taker_contracts.create)
        allowed[:create_localpool_power_taker_contract] = create_localpool_power_taker_contract.success? || create_localpool_power_taker_contract.errors
      end
      if allowed?(permissions.billing_cycles.create)
        allowed[:create_billing_cycle] = create_billing_cycle.success? || create_billing_cycle.errors
      end
      allowed
    end

    def create_metering_point_operator_contract
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Localpool::CreateMeteringPointOperatorContract.call(subject)
    end

    def create_localpool_processing_contract
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Localpool::CreateLocalpoolProcessingContract.call(subject)
    end

    def create_localpool_power_taker_contract
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Localpool::CreateLocalpoolPowerTakerContract.call(subject)
    end

    def create_billing_cycle
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Localpool::CreateBillingCycle.call(subject)
    end

    def deletable
      super && object.owner.nil?
    end

  end
end
