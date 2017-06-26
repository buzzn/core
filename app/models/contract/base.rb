module Contract
  class Base < ActiveRecord::Base
    self.table_name = :contracts
    self.abstract_class = true

    resourcify
    include Filterable

    # status consts
    WAITING   = 'waiting_for_approval'
    APPROVED  = 'approved'
    RUNNING   = 'running'
    CANCELLED = 'cancelled'
    EXPIRED   = 'expired'
    EXCHANGE_PROCESS_PAUSED = 'exchange_process_paused'

    # error messages
    MUST_BE_TRUE                 = 'must be true'
    MUST_HAVE_AT_LEAST_ONE       = 'must have at least one'
    WAS_ALREADY_CANCELLED        = 'was already cancelled'
    MUST_BE_BUZZN_SYSTEMS        = 'must be buzzn-systems'
    MUST_BE_BUZZN                = 'must be buzzn'
    MUST_BELONG_TO_LOCALPOOL     = 'must belong to a localpool'
    MUST_MATCH                   = 'must match'
    IS_MISSING                   = 'is missing'
    CAN_NOT_BE_PRESENT           = 'can not be present when there is a '
    NOT_ALLOWED_FOR_OLD_CONTRACT = 'not allowed for old contract'
    CAN_NOT_BELONG_TO_DUMMY      = 'can not belong to dummy organization'
    MUST_NOT_BE_BUZZN_SYSTEMS    = 'must not be buzzn-systems'
    MUST_NOT_BE_BUZZN            = 'must not be buzzn'



    class << self
      private :new

      def status
        @status ||= [WAITING, APPROVED, RUNNING, CANCELLED, EXPIRED, EXCHANGE_PROCESS_PAUSED]
      end
    end

    # TODO to be removed
    attr_encrypted :password, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

    belongs_to :contractor, polymorphic: true
    belongs_to :customer, polymorphic: true
    belongs_to :signing_user, class_name: 'User'

    has_many :tariffs, class_name: 'Contract::Tariff', foreign_key: :contract_id, dependent: :destroy
    has_many :payments, class_name: 'Contract::Payment', foreign_key: :contract_id, dependent: :destroy

    belongs_to :contractor_bank_account, class_name: 'BankAccount'
    belongs_to :customer_bank_account, class_name: 'BankAccount'

    validates :contractor, presence: true
    validates :customer, presence: true

    validates :status, inclusion: {in: status}

    validates :contract_number, presence: false
    validates :customer_number, presence: false
    validates :origianl_signing_user, presence: false

    validates :signing_date, presence: true
    validates :cancellation_date, presence: false
    validates :end_date, presence: false

    validates :terms_accepted, presence: true
    validates :power_of_attorney, presence: true
    validates_uniqueness_of :contract_number_addition, scope: [:contract_number], message: 'already available for given contract_number', if: 'contract_number_addition.present?'


    validate :validate_invariants

    def initialize(*args)
      super
      self.status = WAITING
    end

    scope :approved,  -> { where(status: APPROVED) }
    scope :running,   -> { where(status: RUNNING) }
    scope :queued,    -> { where(status: WAITING) }
    scope :cancelled, -> { where(status: CANCELLED) }
    scope :expired,   -> { where(status: EXPIRED) }

    scope :power_givers,             -> {where(type: PowerGiver)}
    scope :power_takers,             -> {where(type: PowerTaker)}
    scope :localpool_power_takers,   -> {where(type: LocalpoolPowerTaker)}
    scope :localpool_processing,     -> {where(type: LocalpoolProcessing)}
    scope :metering_point_operators, -> {where(type: MeteringPointOperator)}
    scope :other_suppliers,          -> {where(type: OtherSupplier)}
    scope :localpool_power_takers_and_other_suppliers, ->  {where('type in (?)', [LocalpoolPowerTaker, OtherSupplier])}

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
      errors.add(:terms_accepted, MUST_BE_TRUE ) unless terms_accepted
      errors.add(:power_of_attorney, MUST_BE_TRUE ) unless power_of_attorney
      if contractor
        errors.add(:contractor_bank_account, MUST_MATCH) if contractor_bank_account && ! contractor.bank_accounts.include?(contractor_bank_account)
        if contractor == Organization.buzzn_energy ||
           contractor == Organization.buzzn_systems
          errors.add(:tariffs, MUST_HAVE_AT_LEAST_ONE) if tariffs.size == 0
          errors.add(:payments, MUST_HAVE_AT_LEAST_ONE) if payments.size == 0
        end
      end

      # check lifecycle changes
      if change = changes['status']
        errors.add(:status, WAS_ALREADY_CANCELLED) if change[0] == CANCELLED
      end
    end

    def name
      "TODO {organization.name} {tariff}"
    end

    def full_contract_number
      "#{contract_number}/#{contract_number_addition}"
    end

    def self.search_attributes
      #TODO filtering what ?
      []
    end

    def self.filter(search)
      do_filter(search, *search_attributes)
    end

    def login_required?
      self.organization == Organization.discovergy || self.organization == Organization.mysmartgrid
    end
  end


  class RenewableEnergyLawTaxation
    FULL    = 'full'
    REDUCED = 'reduced'

    class << self
      def all
        @renewable_energy_law_taxation ||= [FULL, REDUCED]
      end
    end
  end
end
