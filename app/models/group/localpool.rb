require_relative 'base'
require_relative '../owner'

module Group
  class Localpool < Base
    include Owner

    belongs_to :grid_consumption_register, class_name: 'Register::Input'
    belongs_to :grid_feeding_register, class_name: 'Register::Output'
    belongs_to :distribution_system_operator, class_name: 'Organization'
    belongs_to :transmission_system_operator, class_name: 'Organization'
    belongs_to :electricity_supplier, class_name: 'Organization'

    has_many :addresses, as: :addressable, dependent: :destroy
    has_many :tariffs, dependent: :destroy, class_name: 'Contract::Tariff', foreign_key: :group_id
    has_many :billing_cycles, dependent: :destroy

    # permissions helpers
    scope :permitted, ->(uuids) { where(id: uuids) }

    def metering_point_operator_contract
      Contract::MeteringPointOperator.where(localpool_id: self).first
    end

    def localpool_processing_contract
      Contract::LocalpoolProcessing.where(localpool_id: self).first
    end

    def localpool_power_taker_contracts
      Contract::LocalpoolPowerTaker.where(localpool_id: self)
    end

    def grid_feeding_register
      registers.grid_feeding.first
    end

    def grid_consumption_register
      registers.grid_consumption.first
    end

    def contracts
      self.class.contracts(self)
    end

    def self.contracts(base = where('1=1')) # take the complete set as default
      Contract::Localpool.joins(:localpool).where(localpool: base)
    end

    def persons
      self.class.persons(self)
    end

    def self.persons(base = where('1=1')) # take the complete set as default
      roles           = Role.arel_table
      persons_roles     = Arel::Table.new(:persons_roles)
      persons         = Person.arel_table
      localpool_users = persons_roles
                        .join(roles)
                        .on(roles[:id].eq(persons_roles[:role_id])
                             .and(roles[:resource_id].eq(base)))
                        .where(persons_roles[:person_id].eq(persons[:id]))
                        .project(1)
                        .exists
      contract_users = contracts(base)
                       .where('contracts.customer_person_id = persons.id or contracts.contractor_person_id = persons.id')
                       .select(1)
                       .exists
      Person.where(localpool_users.or(contract_users))
    end

    def organizations
      self.class.organizations(contracts)
    end

    def self.organizations(base = contracts)
      Organization.where(base.where('contracts.customer_organization_id = organizations.id or contracts.contractor_organization_id = organizations.id')
                  .select(1)
                  .exists)
    end

    def one_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:one_way_meter])
    end

    def two_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:two_way_meter])
    end
  end
end
