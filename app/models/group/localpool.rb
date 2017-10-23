module Group
  class Localpool < Base

    # permissions helpers

    scope :restricted, ->(uuids) { where(id: uuids) }

    belongs_to :organization
    belongs_to :person

    def owner
      organization || person
    end

    def owner=(new_owner)
      if new_owner.is_a?(Person)
        self.person = new_owner
      elsif new_owner.is_a?(Organization)
        self.organization = new_owner
      elsif new_owner.nil?
        # Allow assigning nil, otherwise we can't build a localpool step by step. An unsaved record should be
        # allowed not to have an owner yet.
        # FIXME add invariant validation that an organization must have an owner.
        # FIXME revisit decision to make owner non-polymorphic.
      else
        raise "Can't assign #{new_owner.inspect} as owner, not a Person or Organization."
      end
    end

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

    # TODO: maybe implement this as scope within meter model
    def one_way_meters
      sql = "SELECT m.id FROM meters m, registers r, groups g WHERE r.meter_id = m.id AND r.group_id = g.id AND r.label NOT IN('#{Register::Base::GRID_CONSUMPTION_CORRECTED}', '#{Register::Base::GRID_FEEDING_CORRECTED}') AND g.id = '#{self.id}' GROUP BY m.id HAVING COUNT(*) = 1"
      Meter::Base.find_by_sql("SELECT DISTINCT * FROM meters WHERE id IN(#{sql})")
    end

    # TODO: maybe implement this as scope within meter model
    def two_way_meters
      sql = "SELECT m.id FROM meters m, registers r, groups g WHERE r.meter_id = m.id AND r.group_id = g.id AND r.label NOT IN('#{Register::Base::GRID_CONSUMPTION_CORRECTED}', '#{Register::Base::GRID_FEEDING_CORRECTED}') AND g.id = '#{self.id}' GROUP BY m.id HAVING COUNT(*) > 1"
      Meter::Base.find_by_sql("SELECT DISTINCT * FROM meters WHERE id IN(#{sql})")
    end
  end
end
