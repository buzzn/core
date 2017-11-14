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
               :updatable, :deletable,
               :incompleteness

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

    def incompleteness
      Schemas::Completeness::Admin::Localpool.call(self).messages
    end

  end
end
