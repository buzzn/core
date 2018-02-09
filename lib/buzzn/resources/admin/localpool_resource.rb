require_relative '../group_resource'
require_relative '../person_resource'
require_relative '../contract/tariff_resource'
require_relative 'billing_cycle_resource'
require_relative '../../schemas/completeness/admin/localpool'

module Admin
  class LocalpoolResource < GroupResource

    model Group::Localpool

    attributes :start_date,
               :show_object,
               :show_production,
               :show_energy,
               :show_contact,
               :show_display_app,
               :updatable, :deletable,
               :incompleteness,
               :bank_account,
               :power_sources,
               :display_app_url

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :meters
    has_many :managers, PersonResource
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :organizations
    has_many :contracts
    has_many :registers
    has_many :persons
    has_many :tariffs, Contract::TariffResource
    has_many :billing_cycles, BillingCycleResource
    has_one :owner
    has_one :address
    has_one :distribution_system_operator
    has_one :transmission_system_operator
    has_one :electricity_supplier
    has_one :bank_account

    # TODO remove this and use contructor injection once the resource code
    #      is cleaned up
    attr_reader :display_url
    def initialize(*)
      super
      @display_url = Import.global('config.display_url')
    end

    def meters
      all(permissions.meters, object.meters.real_or_virtual)
    end

    def power_sources
      object.registers.select(:label).production.collect do |register|
        register.label.sub('production_', '')
      end.uniq
    end

    def display_app_url
      if object.show_display_app
        "#{display_url}/#{object.slug}"
      end
    end

  end
end
