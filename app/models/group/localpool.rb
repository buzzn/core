require_relative 'base'
require_relative '../concerns/person_organization_relation'

module Group
  class Localpool < Base

    PersonOrganizationRelation.generate(self, 'owner')
    PersonOrganizationRelation.generate(self, 'gap_contract_customer')

    belongs_to :distribution_system_operator, class_name: 'Organization::Market'
    belongs_to :transmission_system_operator, class_name: 'Organization::Market'
    belongs_to :electricity_supplier, class_name: 'Organization::Market'
    belongs_to :billing_detail, class_name: 'BillingDetail'
    belongs_to :gap_contract_customer_bank_account, class_name: 'BankAccount'

    has_many :devices, foreign_key: :localpool_id
    has_many :tariffs, dependent: :destroy, class_name: 'Contract::Tariff', foreign_key: :group_id

    # Tariffs that are configured for gap contracts
    has_many :group_gap_contract_tariffs, dependent: :destroy, class_name: 'Contract::GroupGapContractTariff', foreign_key: :group_id
    has_many :gap_contract_tariffs, class_name: 'Contract::Tariff', through: :group_gap_contract_tariffs, source: :tariff

    has_many :billing_cycles, dependent: :destroy

    has_many :metering_point_operator_contracts, class_name: 'Contract::MeteringPointOperator', foreign_key: :localpool_id
    has_many :localpool_processing_contracts, class_name: 'Contract::LocalpoolProcessing', foreign_key: :localpool_id
    has_many :localpool_power_taker_contracts, class_name: 'Contract::LocalpoolPowerTaker', foreign_key: :localpool_id
    has_many :localpool_third_party_contracts, class_name: 'Contract::LocalpoolThirdParty', foreign_key: :localpool_id
    has_many :localpool_gap_contracts, class_name: 'Contract::LocalpoolGap', foreign_key: :localpool_id
    has_many :localpool_contracts, class_name: 'Contract::Base', foreign_key: :localpool_id

    has_many :register_metas_by_contracts, class_name: 'Register::Meta', through: :localpool_contracts, foreign_key: :register_meta_id, source: :register_meta

    has_and_belongs_to_many :documents, cass_name: 'Document', join_table: 'groups_documents', foreign_key: :group_id

    def register_metas
      Register::Meta.where(:id => (self.register_metas_by_contracts.pluck(:id) + self.register_metas_by_registers.pluck(:id)).uniq)
    end

    def metering_point_operator_contract
      self.metering_point_operator_contracts.each do |mpoc|
        next if [Contract::Base::TERMINATED, Contract::Base::ENDED].include? mpoc.status
        return mpoc
      end
      nil
    end

    def localpool_processing_contract
      active_localpool_processing_contract(Date.today)
    end

    def active_localpool_processing_contract(at)
      self.localpool_processing_contracts.to_a.each do |lpc|
        next if [Contract::Base::TERMINATED, Contract::Base::ENDED].include? lpc.status(at)
        return lpc
      end
      nil
    end

    def localpool_power_taker_and_third_party_contracts
      Contract::Base.where(localpool_id: self, type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolThirdParty))
    end

    def grid_feeding_register
      registers.joins(:meta).where('register_meta.label': 'GRID_FEEDING').first
    end

    def grid_consumption_register
      registers.joins(:meta).where('register_meta.label': 'GRID_CONSUMPTION').first
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
      localpool_owner = if base.is_a?(Group::Localpool)
                          localpool.where(localpool[:id].eq(base).and(localpool[:owner_person_id].eq(persons[:id]))).project(1).exists
                        else
                          base.where('groups.owner_person_id=persons.id').project(1).exists
                        end
      localpool_gap_contract_customer = if base.respond_to?(:to_a)
                                          base.where('groups.gap_contract_customer_person_id=persons.id').project(1).exists
                                        else
                                          localpool.where(localpool[:id].eq(base).and(localpool[:gap_contract_customer_person_id].eq(persons[:id]))).project(1).exists
                                        end
      Person.where(localpool_owner.or(localpool_users).or(contract_users).or(localpool_gap_contract_customer))
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
      localpool_gap_contract_customer = if base.respond_to?(:to_a)
                                          base.where('groups.gap_contract_customer_organization_id=organizations.id').project(1).exists
                                        else
                                          localpool.where(localpool[:id].eq(base).and(localpool[:gap_contract_customer_organization_id].eq(organizations[:id]))).project(1).exists
                                        end
      Organization::General.where(localpool_owner.or(contract_organizations).or(localpool_gap_contract_customer))
    end

    def one_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:one_way_meter])
    end

    def two_way_meters
      meter_without_corrected_registers.where(direction_number: Meter::Real.direction_numbers[:two_way_meter])
    end

    def contexted_gap_contract_tariffs
      Service::Tariffs.data(self.gap_contract_tariffs)
    end

    def next_billing_cycle_begin_date
      if billing_cycles.empty?
        self.start_date
      else
        unvoided_cycles = self.billing_cycles.order(:begin_date).reject { |x| x.status == 'void' }
        if unvoided_cycles.any?
          unvoided_cycles.last.end_date
        else
          self.start_date
        end
      end
    end

  end
end
