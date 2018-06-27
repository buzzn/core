require_relative 'base'
require_relative '../concerns/person_organization_relation'

module Group
  class Localpool < Base

    PersonOrganizationRelation.generate(self, 'owner')
    PersonOrganizationRelation.generate(self, 'gap_contract_customer')

    belongs_to :grid_consumption_register, class_name: 'Register::Input'
    belongs_to :grid_feeding_register, class_name: 'Register::Output'
    belongs_to :distribution_system_operator, class_name: 'Organization::Market'
    belongs_to :transmission_system_operator, class_name: 'Organization::Market'
    belongs_to :electricity_supplier, class_name: 'Organization::Market'

    has_many :devices, foreign_key: :localpool_id
    has_many :tariffs, dependent: :destroy, class_name: 'Contract::Tariff', foreign_key: :group_id
    has_many :billing_cycles, dependent: :destroy

    def metering_point_operator_contract
      Contract::MeteringPointOperator.where(localpool_id: self).first
    end

    def localpool_processing_contract
      Contract::LocalpoolProcessing.where(localpool_id: self).first
    end

    def localpool_power_taker_contracts
      Contract::Base.where(localpool_id: self, type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolThirdParty))
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

    def self.contracts(base = where('1=1')) # means take all localpools
      if base.is_a?(Group::Localpool)
        Contract::Localpool.where(localpool: base)
      else
        Contract::Localpool.joins(:localpool).where(localpool: base)
      end
    end

    def persons
      self.class.persons(self)
    end

    def self.persons(base = self.all) #where('1=1')) # means take all localpools
      roles = Role.arel_table
      persons_roles = Arel::Table.new(:persons_roles)
      persons = Person.arel_table
      localpool_ids =
        if base.is_a?(Group::Localpool)
          base.id
        else
          base.select(:id).pluck(:id)
        end
      localpool_users = persons_roles
                        .join(roles)
                        .on(roles[:id].eq(persons_roles[:role_id])
                             .and(roles[:resource_id].in(localpool_ids)))
                        .where(persons_roles[:person_id].eq(persons[:id]))
                        .project(1)
                        .exists
      contract_users = contracts(base)
                       .where('contracts.customer_person_id = persons.id or contracts.contractor_person_id = persons.id')
                       .select(1)
                       .exists
      localpool = Localpool.arel_table
      localpool_owner =
        if base.is_a?(Group::Localpool)
          localpool.where(localpool[:id].eq(base).and(localpool[:owner_person_id].eq(persons[:id]))).project(1).exists
        else
          base.where('groups.owner_person_id=persons.id').project(1).exists
        end
      Person.where(localpool_owner.or(localpool_users).or(contract_users))
    end

    def organizations
      self.class.organizations(self)
    end

    def self.organizations(base = where('1=1'))
      organizations = Organization::General.arel_table
      localpool = Localpool.arel_table
      localpool_owner =
        if base.respond_to?(:to_a)
          base.where('groups.owner_organization_id=organizations.id').project(1).exists
        else
          localpool.where(localpool[:id].eq(base).and(localpool[:owner_organization_id].eq(organizations[:id]))).project(1).exists
        end

      contract_organizations = contracts(base).where('contracts.customer_organization_id = organizations.id or contracts.contractor_organization_id = organizations.id')
                                              .select(1)
                                              .exists
      Organization::General.where(localpool_owner.or(contract_organizations))
    end

    def one_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:one_way_meter])
    end

    def two_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:two_way_meter])
    end

  end
end
