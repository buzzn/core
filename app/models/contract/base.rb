require 'active_support/string_inquirer'
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
    has_many :billing_items, through: :billings, :source => 'items'
    has_many :accounting_entries, class_name: 'Accounting::Entry', foreign_key: :contract_id
    has_and_belongs_to_many :documents, foreign_key: :contract_id
    has_and_belongs_to_many :comments, foreign_key: :contract_id, join_table: 'comments_contracts', class_name: 'Comment'

    belongs_to :contractor_bank_account, class_name: 'BankAccount'
    belongs_to :customer_bank_account, class_name: 'BankAccount'
    belongs_to :register_meta, class_name: 'Register::Meta', foreign_key: :register_meta_id
    belongs_to :register_meta_option, class_name: 'Register::MetaOption', foreign_key: :register_meta_option_id

    before_save :check_contract_number
    before_create :check_contract_number

    # status consts
    ONBOARDING = 'onboarding'
    SIGNED     = 'signed'
    ACTIVE     = 'active'
    TERMINATED = 'terminated'
    ENDED      = 'ended'
    STATUS     = [ONBOARDING, SIGNED, ACTIVE, TERMINATED, ENDED]

    STATUS.each { |s| delegate "#{s}?", to: :status } # adds status query methods like contract.active?

    scope :other_suppliers,          -> { where(type: 'OtherSupplier') }
    scope :for_localpool,            -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty))}
    scope :localpool_power_takers_and_other_suppliers, -> {where('type in (?)', %w(LocalpoolPowerTaker OtherSupplier))}
    scope :running_in_year, ->(year) do
      where('begin_date <= ?', Date.new(year, 12, 31)).where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1))
    end
    scope :at, ->(timestamp) do
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
        .where('end_date > ? OR end_date IS NULL', timestamp)
    end

    scope :without_third_party, -> { where.not(type: 'Contract::LocalpoolThirdParty') }

    def full_contract_number
      "#{contract_number}/#{contract_number_addition}"
    end

    def status(at = nil)
      at ||= Date.today
      status = if end_date && end_date <= at
                 ENDED
      elsif termination_date && termination_date <= at
        TERMINATED
      elsif begin_date && begin_date <= at
        ACTIVE
      elsif signing_date && signing_date <= at
        SIGNED
      else
        ONBOARDING
      end
      # wrap the string in ActiveSupport::StringInquirer, which allows status.ended? etc, hiding the string.
      ActiveSupport::StringInquirer.new(status)
    end

    def contact
      if customer.is_a? Person
        return customer
      elsif customer.is_a? Organization::Base
        return customer.contact
      end
    end


    def balance_sheet
      Accounting::BalanceSheet.new(self)
    end

    def pdf_generator
      nil
    end

    protected

    def check_contract_number
      return
    end

    private

    # permissions helpers
    scope :permitted, ->(uids) { where(id: uids) }

  end
end
