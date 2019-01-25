require_relative 'concerns/last_date'
require_relative 'concerns/with_date_range'
require_relative 'concerns/date_range_scope'

class Billing < ActiveRecord::Base

  include LastDate
  include WithDateRange
  include DateRangeScope

  enum status: %i(open calculated delivered settled closed).each_with_object({}) { |i, o| o[i] = i.to_s }

  belongs_to :billing_cycle
  belongs_to :contract, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base'
  belongs_to :accounting_entry, class_name: 'Accounting::Entry'

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

  def full_invoice_number
    if self.invoice_number_addition.nil?
      self.invoice_number
    else
      "#{self.invoice_number}/#{self.invoice_number_addition}"
    end
  end

  def generate_invoice_number
    "#{Date.today.year}-#{contract.contract_number}"
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

end
