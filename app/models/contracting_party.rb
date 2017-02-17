class ContractingParty < ActiveRecord::Base
  self.abstract_class = true

  has_many :owned_contracts, class_name: 'Contract', foreign_key: 'contractor_id'
  has_many :assigned_contracts, class_name: 'Contract', foreign_key: 'customer_id'

  has_one :address, as: :addressable, dependent: :destroy

  has_one :bank_account, as: :bank_accountable, dependent: :destroy

  validates_associated :address
  validates_associated :bank_account
  validates :sales_tax_number, presence: false
  validates :tax_rate, presence: false
  validates :tax_number, presence: false
  validates :retailer, presence: false
  validates :provider_permission, presence: false
  validates :subject_to_tax, presence: false
  validates :mandate_reference, presence: false

  # TODO ????
  validates :creditor_id, presence: false

  validate :validate_invariants

  def validate_invariants
    if contracts.size > 0
      errors.add(:address, 'is missing') unless address
    end
    # TODO something like this:
    #if owned_contracts.size > 0
    #  errors.add(:bank_account, 'is missing') unless bank_account
    #end
  end

  def contracts
    Contract.where("contractor_id = ? OR customer_id = ?", self.id, self.id)
  end

  def self.readable_by_query(user)
    contracting_party = ContractingParty.arel_table
    if user
      contracting_party[:id].eq(contracting_party[:id])
    else
      contracting_party[:id].eq(contracting_party[:id]).not
    end
  end

  scope :readable_by, -> (user) do
    where(readable_by_query(user))
  end

end
