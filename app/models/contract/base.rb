require_relative '../filterable'
require_relative '../concerns/last_date'
require_relative '../concerns/date_range_scope'
require_relative '../concerns/person_organization_relation'

module Contract
  class Base < ActiveRecord::Base

    self.table_name = :contracts
    self.abstract_class = true

    include Filterable
    include LastDate
    include DateRangeScope

    PersonOrganizationRelation.generate(self, 'customer')
    PersonOrganizationRelation.generate(self, 'contractor')

    enum renewable_energy_law_taxation: {
           full: 'F',
           reduced: 'R',
           null: 'N' # none is not allowed by active-record
         }

    class << self

      def search_attributes
        # TODO: filtering what ?
        []
      end

      def filter(search)
        do_filter(search, *search_attributes)
      end

    end

    has_and_belongs_to_many :tariffs, class_name: 'Contract::Tariff', foreign_key: :contract_id
    has_many :payments, class_name: 'Contract::Payment', foreign_key: :contract_id, dependent: :destroy
    has_many :billings, foreign_key: :contract_id

    belongs_to :contractor_bank_account, class_name: 'BankAccount'
    belongs_to :customer_bank_account, class_name: 'BankAccount'
    belongs_to :market_location

    # status consts
    ONBOARDING = 'onboarding'
    ACTIVE     = 'active'
    TERMINATED = 'terminated'
    ENDED      = 'ended'
    STATUS     = [ONBOARDING, ACTIVE, TERMINATED, ENDED]

    STATUS.each { |s| delegate "#{s}?", to: :status } # adds status query methods like contract.active?

    scope :power_givers,             -> { where(type: 'PowerGiver') }
    scope :power_takers,             -> { where(type: 'PowerTaker') }
    scope :localpool_power_takers,   -> { where(type: 'LocalpoolPowerTaker') }
    scope :localpool_processing,     -> { where(type: 'LocalpoolProcessing') }
    scope :metering_point_operators, -> { where(type: 'MeteringPointOperator') }
    scope :other_suppliers,          -> { where(type: 'OtherSupplier') }
    scope :for_market_locations,     -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty))}
    scope :localpool_power_takers_and_other_suppliers, -> {where('type in (?)', %w(LocalpoolPowerTaker OtherSupplier))}
    scope :running_in_year,   -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                          .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) do
      timestamp = case timestamp
                  when DateTime
                    timestamp.to_date
                  when Time
                    timestamp.to_date
                  when Date
                    timestamp
                  when Integer
                    Time.at(timestamp).to_date
                  else
                    raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                  end
      where('begin_date <= ?', timestamp)
        .where('end_date > ? OR end_date IS NULL', timestamp + 1.second)
    end

    scope :without_third_party, -> { where.not(type: 'Contract::LocalpoolThirdParty') }

    def full_contract_number
      "#{contract_number}/#{contract_number_addition}"
    end

    def status
      today = Date.today
      status = if end_date && end_date <= today
                 ENDED
      elsif termination_date
        TERMINATED
      elsif begin_date && begin_date <= today
        ACTIVE
      else
        ONBOARDING
      end
      # wrap the string in ActiveSupport::StringInquirer, which allows status.ended? etc, hiding the string.
      status.inquiry
    end

    private

    # permissions helpers
    scope :permitted, ->(uids) { where(id: uids) }

  end
end
