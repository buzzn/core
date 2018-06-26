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
  has_many :billings, through: :contracts

  # Fully implementing 1:n, i.e. that a market location has many current and past registers is a future story.
  # I'm already setting things up 1:n on the DB and association level, hopefully that'll make implementation
  # easier later on.
  has_many :registers, class_name: 'Register::Base'
  private :registers

  def contracts_in_date_range(date_range)
    contracts.in_date_range(date_range)
  end

  def billings_in_date_range(date_range)
    billings.in_date_range(date_range)
  end

  def register
    registers.first
  end

  def register=(new_register)
    self.registers = new_register ? [new_register] : []
  end

  # FIXME broken
  scope :permitted, ->(uids) { joins(:contracts).where('contracts.id': uids) }

  def consumption?
    register.label.consumption?
  end

end
