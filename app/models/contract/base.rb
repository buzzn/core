require_relative '../filterable'
require_relative '../owner'

module Contract
  class Base < ActiveRecord::Base
    self.table_name = :contracts
    self.abstract_class = true

    include Filterable
    Owner.generate(self, 'customer')
    Owner.generate(self, 'contractor')

    # status consts
    ONBOARDING = 'onboarding'
    ACTIVE     = 'active'
    TERMINATED = 'terminated'
    ENDED      = 'ended'
    STATUS     = [ONBOARDING, ACTIVE, TERMINATED, ENDED]

    enum renewable_energy_law_taxation: {
           full: 'F',
           reduced: 'R',
           null: 'N' # none is not allowed by active-record
         }

    # error messages
    MUST_BE_TRUE                 = 'must be true'
    MUST_HAVE_AT_LEAST_ONE       = 'must have at least one'
    WAS_ALREADY_CANCELLED        = 'was already cancelled'
    MUST_BE_BUZZN                = 'must be buzzn'
    MUST_BELONG_TO_LOCALPOOL     = 'must belong to a localpool'
    MUST_MATCH                   = 'must match'
    IS_MISSING                   = 'is missing'
    CAN_NOT_BE_PRESENT           = 'can not be present when there is a '
    NOT_ALLOWED_FOR_OLD_CONTRACT = 'not allowed for old contract'
    MUST_NOT_BE_BUZZN            = 'must not be buzzn'

    class << self
      private :new
    end

    has_and_belongs_to_many :tariffs, class_name: 'Contract::Tariff', foreign_key: :contract_id
    has_many :payments, class_name: 'Contract::Payment', foreign_key: :contract_id, dependent: :destroy

    belongs_to :contractor_bank_account, class_name: 'BankAccount'
    belongs_to :customer_bank_account, class_name: 'BankAccount'

    scope :power_givers,             -> { where(type: 'PowerGiver') }
    scope :power_takers,             -> { where(type: 'PowerTaker') }
    scope :localpool_power_takers,   -> { where(type: 'LocalpoolPowerTaker') }
    scope :localpool_processing,     -> { where(type: 'LocalpoolProcessing') }
    scope :metering_point_operators, -> { where(type: 'MeteringPointOperator') }
    scope :other_suppliers,          -> { where(type: 'OtherSupplier') }
    scope :localpool_power_takers_and_other_suppliers, ->  {where('type in (?)', %w(LocalpoolPowerTaker OtherSupplier))}

    scope :running_in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                          .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) do
      timestamp = case timestamp
                  when DateTime
                    timestamp.to_date
                  when Time
                    timestamp.to_date
                  when Date
                    timestamp
                  when Fixnum
                    Time.at(timestamp).to_date
                  else
                    raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                  end
      where('begin_date <= ?', timestamp)
        .where('end_date > ? OR end_date IS NULL', timestamp + 1.second)
    end

    def validate_invariants
      errors.add(:power_of_attorney, MUST_BE_TRUE ) unless power_of_attorney
      if contractor
        errors.add(:contractor_bank_account, MUST_MATCH) if contractor_bank_account && ! contractor.bank_accounts.include?(contractor_bank_account)
        if contractor_is_buzzn?
          errors.add(:tariffs, MUST_HAVE_AT_LEAST_ONE) if tariffs.empty?
          # FIXME: why is at least one payment required?
          errors.add(:payments, MUST_HAVE_AT_LEAST_ONE) if payments.empty?
        end
      end
    end

    def name
      "TODO {organization.name} {tariff}"
    end

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

    def self.search_attributes
      #TODO filtering what ?
      []
    end

    def self.filter(search)
      do_filter(search, *search_attributes)
    end

    private

    def contractor_is_buzzn?
      contractor.is_a?(Organization) && contractor.buzzn?
    end
  end
end
