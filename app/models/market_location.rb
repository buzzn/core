#
# Represents a physical point of energy consumption or production, independently of the energy metering
# hardware and contracts (which both can change over time). Examples are a flat, an office.
#
# "Marktlokation" is a term defined in German energy legislation as well, see for details:
# https://de.wikipedia.org/wiki/Marktlokations-Identifikationsnummer
#
# When a "Marktlokation" is for consumed energy, we use the less nerdy term "Entnahmestelle".
#
class MarketLocation < ActiveRecord::Base

  belongs_to :group, class_name: 'Group::Base'
  has_many :contracts, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base'

  # Fully implementing 1:n, i.e. that a market location has many current and past registers is a future story.
  # I'm already setting things up 1:n on the DB and association level, hopefully that'll make implementation
  # easier later on.
  has_many :registers, class_name: 'Register::Base'
  private :registers

  def billable_contracts_for_range(date_range)
    contracts
      .where('end_date IS NULL OR end_date > ?', date_range.first) # fetch contracts running or ended in the period
      .where.not('begin_date >= ?', date_range.last) # don't fetch contracts starting after the period
      .order(:begin_date) # ensure chronological order to ease testing
  end

  def register
    registers.first
  end

  def register=(new_register)
    self.registers = new_register ? [new_register] : []
  end

  delegate :consumption?, to: :register

  scope :permitted, ->(uids) { joins(:contracts).where('contracts.id': uids) }

end
