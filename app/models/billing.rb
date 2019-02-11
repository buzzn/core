require_relative 'concerns/last_date'
require_relative 'concerns/with_date_range'
require_relative 'concerns/date_range_scope'
require_relative '../state_machines/billing'

require 'buzzn/types/billing_config'

class Billing < ActiveRecord::Base

  include LastDate
  include WithDateRange
  include DateRangeScope

  enum status: StateMachine::Billing.states.each_with_object({}) { |i, o| o[i] = i.to_s }

  belongs_to :billing_cycle
  belongs_to :contract, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base'
  belongs_to :accounting_entry, class_name: 'Accounting::Entry'
  belongs_to :adjusted_payment, class_name: 'Contract::Payment'

  has_and_belongs_to_many :documents, join_table: 'billings_documents', class_name: 'Document'

  has_one :localpool, through: :contract

  has_many :items, class_name: 'BillingItem', dependent: :destroy

  scope :for_group, ->(group) { includes(:contract).where(contracts: { localpool_id: group.id }) }

  before_save :check_invoice_number
  before_create :check_invoice_number

  def localpool
    contract.localpool
  end

  def singular?
    self.billing_cycle.nil?
  end

  def allowed_transitions
    StateMachine::Billing.transitions_for(self.status.to_sym)
  end

  def transition_to(status)
    action = StateMachine::Billing.transition_action(self.status.to_sym, status.to_sym)
    self.status = status
    action
  end

  def full_invoice_number
    if self.invoice_number_addition.nil?
      self.invoice_number
    else
      "#{self.invoice_number}-#{self.invoice_number_addition}"
    end
  end

  def generate_invoice_number
    "#{Date.today.year}-#{contract.full_contract_number}"
  end

  def check_invoice_number_addition
    if self.invoice_number_addition.nil?
      self.invoice_number_addition = (Billing.where(:invoice_number => self.invoice_number).maximum(:invoice_number_addition) || 0) + 1
    end
  end

  def check_invoice_number
    if self.invoice_number.nil?
      self.invoice_number = generate_invoice_number
      self.check_invoice_number_addition
    end
  end

  def total_amount_before_taxes
    amount = 0
    items.each do |item|
      amount += item.energy_price_cents + item.base_price_cents
    end
    amount
  end

  def total_amount_after_taxes
    billing_config = CoreConfig.load(Types::BillingConfig)
    if billing_config.nil?
      raise 'please set Types::BillingConfig'
    end
    total_amount_before_taxes * billing_config.vat
  end

  def total_consumed_energy_kwh
    total = 0
    items.each do |item|
      total += item.consumed_energy_kwh
    end
    total
  end

  def daily_kwh_estimate
    total = 0
    items.each do |item|
      total += item.consumed_energy_kwh / (item.length_in_days * 1.0)
    end
    total
  end

  # in decacents
  def balance_before
    accounting_service = Import.global('services.accounting')
    if self.accounting_entry.nil?
      0
    else
      accounting_service.balance_before(self.accounting_entry)
    end
  end

end
