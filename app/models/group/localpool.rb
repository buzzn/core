module Group
  class Localpool < Base
    include Owner

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
                       .where('contracts.customer_id = persons.id or contracts.contractor_id = persons.id')
                       .select(1)
                       .exists
      Person.where(localpool_users.or(contract_users))
    end

    def organizations
      self.class.organizations(contracts)
    end

    def self.organizations(base = contracts)
      Organization.where(base.where('contracts.customer_id = organizations.id or contracts.contractor_id = organizations.id')
                  .select(1)
                  .exists)
    end

    def meters
      Meter::Base.where(id: registers.select(:meter_id))
    end

    has_many :addresses, as: :addressable, dependent: :destroy
    has_many :prices, dependent: :destroy
    has_many :billing_cycles, dependent: :destroy

    def meter_without_corrected_registers
      # TODO is this the same as:

      # Meter::Base.where(id: registers.where('label NOT IN (?)', [Register::Base.labels[:grid_consumption_corrected], Register::Base.labels[:grid_feeding_corrected]]).select(:meter_id))

      # ?

      Meter::Real.where(id: registers.select(:meter_id))
    end

    def one_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:one_way_meter])
    end

    def two_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:two_way_meter])
    end
  end
end
