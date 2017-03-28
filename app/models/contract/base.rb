module Contract
  class Base < ActiveRecord::Base
    self.table_name = :contracts
    self.abstract_class = true

    resourcify
    include Authority::Abilities
    include Filterable
    include Buzzn::GuardedCrud

    # status consts
    WAITING   = 'waiting_for_approval'
    APPROVED  = 'approved'
    RUNNING   = 'running'
    CANCELLED = 'cancelled'
    EXPIRED   = 'expired'

    # error messages
    MUST_BE_TRUE                 = 'must be true'
    MUST_HAVE_AT_LEAST_ONE       = 'must have at least one'
    WAS_ALREADY_CANCELLED        = 'was already cancelled'
    MUST_BE_BUZZN_SYSTEMS        = 'must be buzzn-systems'
    MUST_BE_BUZZN                = 'must be buzzn'
    MUST_BELONG_TO_LOCALPOOL     = 'must belong to a localpool'
    IS_MISSING                   = 'is missing'
    CAN_NOT_BE_PRESENT           = 'can not be present when there is a '
    NOT_ALLOWED_FOR_OLD_CONTRACT = 'not allowed for old contract'
    CAN_NOT_BELONG_TO_DUMMY      = 'can not belong to dummy organization'
    MUST_NOT_BE_BUZZN_SYSTEMS    = 'must not be buzzn-systems'
    MUST_NOT_BE_BUZZN            = 'must not be buzzn'

    class << self
      private :new

      def status
        @status ||= [WAITING, APPROVED, RUNNING, CANCELLED, EXPIRED]
      end
    end

    # TODO to be removed
    attr_encrypted :password, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

    belongs_to :contractor, polymorphic: true
    belongs_to :customer, polymorphic: true
    belongs_to :signing_user, class_name: 'User'

    has_many :tariffs, class_name: 'Contract::Tariff', foreign_key: :contract_id, dependent: :destroy
    has_many :payments, class_name: 'Contract::Payment', foreign_key: :contract_id, dependent: :destroy

    has_one :bank_account, as: :bank_accountable, dependent: :destroy

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

    scope :running_in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                          .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }

    def self.readable_by_query(user)
      contract = Contract::Base.arel_table
      if user
        User.roles_query(user, manager: [contract[:register_id], contract[:localpool_id]], admin: nil).project(1).exists
      else
        # always false, i.e. anonymous users can not see contracts
        contract[:id].eq(contract[:id]).not
      end
    end

    scope :readable_by, -> (user) do
      where(readable_by_query(user))
    end

    def validate_invariants
      errors.add(:terms_accepted, MUST_BE_TRUE ) unless terms_accepted
      errors.add(:power_of_attorney, MUST_BE_TRUE ) unless power_of_attorney
      if contractor
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
end
